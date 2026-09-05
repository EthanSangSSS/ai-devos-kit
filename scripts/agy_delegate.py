#!/usr/bin/env python3
"""Run one bounded Agy delegation and emit selective JSON telemetry."""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import re
import selectors
import signal
import subprocess
import sys
import time
from typing import Any, Iterable


BINARY = "/Users/ethan/.local/bin/agy"
EXPECTED_MODEL = "gemini-3.8-flash-high"
EXPECTED_EFFORT = "high"
EXPECTED_MODE = "plan"
DEFAULT_TIMEOUT_SECONDS = 75.0
MAX_TIMEOUT_SECONDS = 90.0
CLI_PRINT_TIMEOUT = "60s"
MAX_PACKET_BYTES = 4096
MAX_OUTPUT_BYTES = 1024 * 1024
SMOKE_PROMPT = (
    "Do not call any tools. Return only the required structured JSON object with "
    'claim set to "HEALTH_OK", empty changed_paths, validation, and risks, and '
    "pushed and pr_mutated set to false."
)
FINAL_SCHEMA: dict[str, Any] = {
    "type": "object",
    "properties": {
        "claim": {"type": "string"},
        "changed_paths": {"type": "array", "items": {"type": "string"}},
        "validation": {"type": "array", "items": {"type": "string"}},
        "risks": {"type": "array", "items": {"type": "string"}},
        "pushed": {"type": "boolean", "enum": [False]},
        "pr_mutated": {"type": "boolean", "enum": [False]},
    },
    "required": ["claim", "changed_paths", "validation", "risks", "pushed", "pr_mutated"],
    "additionalProperties": False,
}
FINAL_KEYS = tuple(FINAL_SCHEMA["properties"])
_SECRET_RE = re.compile(
    r"(?i)(bearer\s+|(?:access[_-]?token|refresh[_-]?token|api[_-]?key|client[_-]?secret)\s*[:=]\s*[\"']?)([^\s,\"'}]+)"
)
_UNSAFE_RE = re.compile(
    r"(?i)(^|[/\s])(?:\.env(?:$|[./\s])|\.ssh(?:$|[/\s])|keychain|password|api[_-]?key|access[_-]?token|secret)"
)


class DelegateError(ValueError):
    """Stable wrapper classification with a process exit code."""

    def __init__(self, classification: str, exit_code: int, detail: str = "") -> None:
        self.classification = classification
        self.exit_code = exit_code
        super().__init__(f"{classification}{(': ' + detail) if detail else ''}")


def _expected_cwd(cwd: str | os.PathLike[str]) -> str:
    return os.path.abspath(os.path.expanduser(os.fspath(cwd)))


def _run_cwd(cwd: str | os.PathLike[str]) -> str:
    path = Path(cwd).expanduser().resolve()
    if not path.is_dir():
        raise DelegateError("WORKSPACE_INVALID", 64)
    return str(path)


def _redact(value: Any, *, limit: int = 300) -> Any:
    if isinstance(value, str):
        text = _SECRET_RE.sub(r"\1<redacted>", value).replace(str(Path.home()), "$HOME")
        return " ".join(text.split())[:limit]
    if isinstance(value, list):
        return [_redact(item, limit=limit) for item in value[:200]]
    if isinstance(value, dict):
        return {str(key): _redact(item, limit=limit) for key, item in value.items()}
    return value


def command() -> list[str]:
    """Return the pinned invocation; optional profiles and fallbacks are absent."""

    schema = json.dumps(FINAL_SCHEMA, ensure_ascii=False, separators=(",", ":"))
    return [
        BINARY,
        "--print=",
        "--model", EXPECTED_MODEL,
        "--effort", EXPECTED_EFFORT,
        "--sandbox",
        "--mode", EXPECTED_MODE,
        "--output-format", "stream-json",
        "--input-format", "stream-json",
        "--print-timeout", CLI_PRINT_TIMEOUT,
        "--json-schema", schema,
    ]


def build_input_event(prompt: str) -> str:
    if not isinstance(prompt, str) or not prompt.strip():
        raise DelegateError("PACKET_INVALID", 64)
    event = json.dumps(
        {"event": "user", "message": {"role": "user", "content": prompt}},
        ensure_ascii=False,
        separators=(",", ":"),
    ) + "\n"
    if len(event.encode("utf-8")) > MAX_PACKET_BYTES:
        raise DelegateError("PACKET_TOO_LARGE", 64)
    return event


def build_packet(goal: str, allowed_scope: Iterable[str], authority: str) -> str:
    """Build a normal request's explicit goal, scope, and authority packet."""

    if not isinstance(goal, str) or not isinstance(authority, str) or isinstance(allowed_scope, (str, bytes)):
        raise DelegateError("PACKET_INVALID", 64)
    scopes = [str(item).strip() for item in allowed_scope if str(item).strip()]
    if not goal.strip() or not scopes or not authority.strip():
        raise DelegateError("PACKET_INVALID", 64)
    if any(Path(scope).is_absolute() or ".." in Path(scope).parts or scope.startswith("~") for scope in scopes):
        raise DelegateError("PACKET_UNSAFE", 64)
    if _UNSAFE_RE.search(f"{goal} {' '.join(scopes)} {authority}"):
        raise DelegateError("PACKET_UNSAFE", 64)
    return "\n".join(
        [
            "Bounded execution packet",
            f"Goal: {goal.strip()}",
            "Allowed scope:",
            *[f"- {scope}" for scope in scopes],
            f"Authority: {authority.strip()}",
            "Out of scope: credentials, auth state, .env files, remote writes, push, merge, deploy, and PR mutation.",
            "Return only the required structured JSON result; do not add unsupported properties.",
        ]
    )


def validate_event(event: dict[str, Any], cwd: str | os.PathLike[str]) -> dict[str, Any]:
    """Validate an init event before any later child output is accepted."""

    if not isinstance(event, dict) or event.get("event") != "init":
        raise DelegateError("PROTOCOL", 65)
    init = event.get("init")
    if not isinstance(init, dict):
        raise DelegateError("PROTOCOL", 65)
    if init.get("model") != EXPECTED_MODEL:
        raise DelegateError("MODEL_MISMATCH", 11)
    if init.get("cwd") != _expected_cwd(cwd):
        raise DelegateError("WORKSPACE_MISMATCH", 11)
    return init


def parse_stream(text: str | bytes) -> tuple[list[dict[str, Any]], list[str]]:
    if isinstance(text, bytes):
        text = text.decode("utf-8", errors="replace")
    events: list[dict[str, Any]] = []
    errors: list[str] = []
    for number, line in enumerate(text.splitlines(), 1):
        if not line.strip():
            continue
        try:
            event = json.loads(line)
        except json.JSONDecodeError as exc:
            errors.append(f"line {number}: invalid JSON ({exc.msg})")
            continue
        if not isinstance(event, dict):
            errors.append(f"line {number}: event must be an object")
            continue
        events.append(event)
    return events, errors


def _protocol(events: list[dict[str, Any]], cwd: str) -> tuple[dict[str, Any], dict[str, Any]]:
    if not events or any(not isinstance(event, dict) for event in events):
        raise DelegateError("PROTOCOL", 65)
    if events[0].get("event") != "init":
        raise DelegateError("PROTOCOL", 65)
    inits = [event for event in events if event.get("event") == "init"]
    results = [event for event in events if event.get("event") == "result"]
    if len(inits) != 1 or len(results) != 1 or events[-1].get("event") != "result":
        raise DelegateError("PROTOCOL", 65)
    init = validate_event(inits[0], cwd)
    result = results[0].get("result")
    if not isinstance(result, dict) or events.index(results[0]) < events.index(inits[0]):
        raise DelegateError("PROTOCOL", 65)
    return init, result


def _final_errors(value: Any) -> list[str]:
    if not isinstance(value, dict):
        return ["final must be an object"]
    errors = [f"missing {key}" for key in FINAL_KEYS if key not in value]
    errors.extend(f"unsupported {key}" for key in sorted(set(value) - set(FINAL_KEYS)))
    if not isinstance(value.get("claim"), str):
        errors.append("claim must be a string")
    for key in ("changed_paths", "validation", "risks"):
        items = value.get(key)
        if not isinstance(items, list) or any(not isinstance(item, str) for item in items):
            errors.append(f"{key} must be a list of strings")
    if value.get("pushed") is not False:
        errors.append("pushed must be false")
    if value.get("pr_mutated") is not False:
        errors.append("pr_mutated must be false")
    return errors


def validate_final(value: Any) -> dict[str, Any]:
    errors = _final_errors(value)
    if errors:
        raise DelegateError("FINAL_INVALID", 13, "; ".join(errors))
    return {key: _redact(value[key]) for key in FINAL_KEYS}


def _tool_events(events: Iterable[dict[str, Any]]) -> list[dict[str, str]]:
    observed: list[dict[str, str]] = []
    for event in events:
        update = event.get("step_update") if event.get("event") == "step_update" else None
        if not isinstance(update, dict) or update.get("step_type") != "tool":
            continue
        name = update.get("tool_name")
        if isinstance(name, str):
            observed.append({"name": _redact(name), "state": _redact(update.get("state") or "")})
    return observed


def summarize(events: list[dict[str, Any]], cwd: str | os.PathLike[str], exit_code: int) -> dict[str, Any]:
    """Return telemetry only after protocol, status, and final schema pass."""

    init, result = _protocol(events, _expected_cwd(cwd))
    if exit_code != 0:
        raise DelegateError("CLI_NONZERO", 12)
    if result.get("status") != "SUCCESS":
        raise DelegateError("RUNTIME_ERROR", 12)
    final = validate_final(result.get("structured_output"))
    tools = [item for item in init.get("tools", []) if isinstance(item, str)]
    calls = _tool_events(events)
    usage = result.get("usage") if isinstance(result.get("usage"), dict) else {}
    return {
        "wrapper_version": 1,
        "classification": "SUCCESS",
        "acceptance": "CLAIMED",
        "controller": {
            "binary": BINARY, "model": EXPECTED_MODEL, "effort": EXPECTED_EFFORT,
            "sandbox": True, "mode": EXPECTED_MODE,
            "input_format": "stream-json", "output_format": "stream-json",
            "remote_write_authority": "NONE",
        },
        "runtime": {
            "cwd": _redact(init.get("cwd")), "init_model": init.get("model"),
            "permission_mode": _redact(init.get("permission_mode")),
            "tool_count": len(tools), "tool_names": _redact(tools),
            "tool_events": calls, "observed_tool_count": len(calls),
        },
        "executor_claim": final,
        "result": {"status": "SUCCESS", "structured_output": final},
        "usage": {key: usage.get(key) for key in ("input_tokens", "output_tokens", "thinking_tokens", "cache_read_tokens", "total_tokens")},
        "verification": {
            "status": "UNVERIFIED", "claim": "CLAIMED", "changed_paths": "UNVERIFIED",
            "validation": "UNVERIFIED", "risks": "UNVERIFIED", "remote_write": "UNVERIFIED",
        },
        "enforcement": {"remote_write_denial": "UNVERIFIED", "remote_write_enforcement": "UNVERIFIED"},
    }


def _terminate_group(process: subprocess.Popen[bytes]) -> None:
    # The group may still contain descendants after the direct child exits.
    try:
        os.killpg(process.pid, signal.SIGTERM)
    except ProcessLookupError:
        pass
    try:
        process.wait(timeout=0.5)
    except subprocess.TimeoutExpired:
        pass
    try:
        os.killpg(process.pid, signal.SIGKILL)
    except ProcessLookupError:
        pass
    try:
        process.wait(timeout=1)
    except subprocess.TimeoutExpired:
        raise DelegateError("TERMINATION_UNVERIFIED", 124)


def _collect(process: subprocess.Popen[bytes], cwd: str, timeout: float) -> tuple[list[dict[str, Any]], list[str], DelegateError | None, bool, list[str]]:
    selector = selectors.DefaultSelector()
    output_bytes = 0
    chunks: dict[str, list[bytes]] = {"out": [], "err": []}
    for stream, label in ((process.stdout, "out"), (process.stderr, "err")):
        if stream is None:
            continue
        os.set_blocking(stream.fileno(), False)
        selector.register(stream, selectors.EVENT_READ, label)
    events: list[dict[str, Any]] = []
    parse_errors: list[str] = []
    out_buffer = b""
    first_checked = False
    early_error: DelegateError | None = None
    timed_out = False
    deadline = time.monotonic() + timeout
    while selector.get_map() and early_error is None:
        remaining = deadline - time.monotonic()
        if remaining <= 0:
            timed_out = True
            _terminate_group(process)
            break
        for key, _ in selector.select(min(remaining, 0.2)):
            stream, label = key.fileobj, key.data
            try:
                data = os.read(stream.fileno(), 65536)
            except BlockingIOError:
                continue
            except OSError:
                data = b""
            if not data:
                selector.unregister(stream)
                continue
            output_bytes += len(data)
            if output_bytes > MAX_OUTPUT_BYTES:
                early_error = DelegateError("OUTPUT_LIMIT", 65)
                _terminate_group(process)
                break
            if label == "err":
                chunks[label].append(data)
            if label != "out":
                continue
            out_buffer += data
            while b"\n" in out_buffer:
                line, _, out_buffer = out_buffer.partition(b"\n")
                try:
                    event = json.loads(line.decode("utf-8", errors="replace"))
                except json.JSONDecodeError as exc:
                    parse_errors.append(f"stream line: invalid JSON ({exc.msg})")
                    early_error = DelegateError("PROTOCOL", 65)
                    _terminate_group(process)
                    break
                if not isinstance(event, dict):
                    parse_errors.append("stream line: event must be an object")
                    early_error = DelegateError("PROTOCOL", 65)
                    _terminate_group(process)
                    break
                if first_checked and (event.get("event") == "init" or any(e.get("event") == "result" for e in events)):
                    early_error = DelegateError("PROTOCOL", 65)
                    _terminate_group(process)
                    break
                events.append(event)
                if not first_checked:
                    first_checked = True
                    try:
                        validate_event(event, cwd)
                    except DelegateError as exc:
                        early_error = exc
                if early_error:
                    _terminate_group(process)
                    break
            if early_error:
                break
    if out_buffer.strip():
        parse_errors.append("stream line: unterminated JSON")
    if timed_out:
        early_error = DelegateError("TIMEOUT", 124)
    try:
        process.wait(timeout=0.5)
    except subprocess.TimeoutExpired:
        _terminate_group(process)
    for stream in (process.stdout, process.stderr):
        if stream is not None:
            stream.close()
    stderr = b"".join(chunks["err"]).decode("utf-8", errors="replace")
    warnings = [_redact(line) for line in stderr.splitlines() if "warn" in line.lower()][:20]
    selector.close()
    return events, parse_errors, early_error, timed_out, warnings


def _failure(error: DelegateError, events: list[dict[str, Any]] | None = None) -> dict[str, Any]:
    events = events or []
    init = events[0].get("init") if events and isinstance(events[0].get("init"), dict) else {}
    result_events = [event for event in events if event.get("event") == "result"]
    result = result_events[-1].get("result") if result_events and isinstance(result_events[-1].get("result"), dict) else {}
    tools = [item for item in init.get("tools", []) if isinstance(item, str)]
    calls = _tool_events(events)
    return {
        "wrapper_version": 1, "classification": error.classification, "acceptance": "UNVERIFIED",
        "error": error.classification,
        "controller": {"binary": BINARY, "model": EXPECTED_MODEL, "effort": EXPECTED_EFFORT,
                        "sandbox": True, "mode": EXPECTED_MODE, "remote_write_authority": "NONE"},
        "runtime": {
            "cwd": _redact(init.get("cwd")), "init_model": init.get("model"),
            "permission_mode": _redact(init.get("permission_mode")),
            "tool_count": len(tools), "tool_names": _redact(tools),
            "tool_events": calls, "observed_tool_count": len(calls),
            "result_status": result.get("status"),
            "structured_output": _redact(result.get("structured_output")),
            "usage": _redact(result.get("usage")),
        },
        "enforcement": {"remote_write_denial": "UNVERIFIED", "remote_write_enforcement": "UNVERIFIED"},
    }


def run(prompt: str, *, cwd: str | os.PathLike[str] | None = None,
        timeout_seconds: float = DEFAULT_TIMEOUT_SECONDS, require_no_tools: bool = False) -> tuple[dict[str, Any], int]:
    if not isinstance(timeout_seconds, (int, float)) or not 0 < float(timeout_seconds) <= MAX_TIMEOUT_SECONDS:
        raise DelegateError("TIMEOUT_INVALID", 64)
    input_bytes = build_input_event(prompt).encode("utf-8")
    canonical_cwd = _run_cwd(cwd or os.getcwd())
    started = time.monotonic()
    try:
        process = subprocess.Popen(command(), cwd=canonical_cwd, stdin=subprocess.PIPE,
                                   stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                   start_new_session=True)
        try:
            assert process.stdin is not None
            process.stdin.write(input_bytes)
            process.stdin.close()
        except BrokenPipeError:
            pass
    except OSError as exc:
        raise DelegateError("LAUNCH_ERROR", 12, str(exc)) from exc
    events, parse_errors, early_error, timed_out, warnings = _collect(process, canonical_cwd, float(timeout_seconds))
    if early_error:
        return _failure(early_error, events), early_error.exit_code
    if parse_errors:
        error = DelegateError("STREAM_PARSE_ERROR", 65)
        return _failure(error, events), error.exit_code
    try:
        summary = summarize(events, canonical_cwd, process.returncode if process.returncode is not None else 0)
    except DelegateError as exc:
        return _failure(exc, events), exc.exit_code
    summary["runtime"]["wall_seconds"] = round(time.monotonic() - started, 3)
    summary["runtime"]["timed_out"] = timed_out
    summary["runtime"]["stderr_warnings"] = warnings
    if require_no_tools and summary["runtime"]["observed_tool_count"]:
        summary["classification"] = "SMOKE_TOOL_USED"
        summary["acceptance"] = "UNVERIFIED"
        return summary, 13
    if require_no_tools and summary["executor_claim"]["claim"] != "HEALTH_OK":
        summary["classification"] = "SMOKE_CLAIM_INVALID"
        summary["acceptance"] = "UNVERIFIED"
        return summary, 13
    return summary, 0


def _args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--smoke", action="store_true", help="run the explicit no-tool HEALTH_OK packet")
    parser.add_argument("--goal", help="bounded goal for a normal delegation")
    parser.add_argument("--allowed-scope", action="append", default=[], help="allowed path or operation; repeatable")
    parser.add_argument("--authority", help="explicit authority granted for this packet")
    parser.add_argument("--cwd", default=os.getcwd(), help="existing project or repository root")
    parser.add_argument("--timeout-seconds", type=float, default=DEFAULT_TIMEOUT_SECONDS)
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = _args(sys.argv[1:] if argv is None else argv)
    try:
        if args.smoke:
            if args.goal or args.allowed_scope or args.authority:
                raise DelegateError("PACKET_INVALID", 64)
            prompt = SMOKE_PROMPT
        else:
            if not args.goal or not args.allowed_scope or not args.authority:
                raise DelegateError("PACKET_INVALID", 64)
            prompt = build_packet(args.goal, args.allowed_scope, args.authority)
        summary, exit_code = run(prompt, cwd=args.cwd, timeout_seconds=args.timeout_seconds, require_no_tools=args.smoke)
    except DelegateError as exc:
        summary, exit_code = _failure(exc), exc.exit_code
    print(json.dumps(_redact(summary), ensure_ascii=False, sort_keys=True))
    return exit_code


if __name__ == "__main__":
    raise SystemExit(main())
