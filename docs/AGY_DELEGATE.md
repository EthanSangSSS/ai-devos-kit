# Bounded Agy delegation

[`scripts/agy_delegate.py`](../scripts/agy_delegate.py) is a small local
process and telemetry wrapper for a single Agy request. It is deliberately transparent:
it launches no fallback executor and does not act as a durable controller.

The command is pinned to the absolute launcher
`/Users/ethan/.local/bin/agy`, model `gemini-3.8-flash-high`, effort `high`,
`--sandbox`, `--mode plan`, and stream-json input and output. The wrapper sends
one event in this shape:

```json
{"event":"user","message":{"role":"user","content":"..."}}
```

The first output event must be `init`. Its `model` and `cwd` must match the
requested identity before later output is accepted. A mismatch terminates the
child process group. The outer timeout is bounded to 90 seconds (75 seconds by
default); the Agy print timeout is 60 seconds.

## Normal delegation

Normal calls require an explicit packet:

```bash
python3 scripts/agy_delegate.py \
  --goal 'make the scoped local change' \
  --allowed-scope scripts/example.py \
  --authority 'local edit and focused tests' \
  --cwd /path/to/repository
```

The packet names the goal, allowed scope, authority, and out-of-scope actions.
A lexical check rejects obvious credential paths, absolute paths and parent traversal before launch. This is not a filesystem access-control policy: symlinks, arbitrary tool commands and remote calls require independent sandbox enforcement.
Remote writes, push, merge, deploy, and PR mutation are always out of scope.

## Fresh smoke

Use `--smoke` for the one-shot trivial health request. It asks the executor to
call no tools and return `claim=HEALTH_OK`; observed tool use or another claim
is a visible failure:

```bash
python3 scripts/agy_delegate.py --smoke > work/evidence/agy-final-smoke.json
```

The wrapper does not expose `--disable-slash-commands` or a generic `--agent`
profile. Disabling slash commands makes Agy ignore plan mode, and the only
advertised profile in this environment is domain-specific.

## Final result and evidence

The executor must return exactly these properties:

```json
{
  "claim": "...",
  "changed_paths": ["..."],
  "validation": ["..."],
  "risks": ["..."],
  "pushed": false,
  "pr_mutated": false
}
```

Unknown properties, missing properties, wrong list item types, or either write
flag set to `true` fail closed. The wrapper reports executor output as
`acceptance=CLAIMED`. Changed paths, validation, and remote-write state remain
independently `UNVERIFIED` until a separate reviewer or Git/GitHub check proves
them. In particular, `pushed=false` and `pr_mutated=false` are executor claims;
they are not enforcement evidence.

The wrapper prints a selective summary only. It does not emit raw stdout,
stderr, tool arguments, credentials, or authentication state. Stable failure
classes are `PACKET_INVALID`, `PACKET_UNSAFE`, `WORKSPACE_INVALID`,
`LAUNCH_ERROR`, `PROTOCOL`, `MODEL_MISMATCH`, `WORKSPACE_MISMATCH`,
`STREAM_PARSE_ERROR`, `CLI_NONZERO`, `RUNTIME_ERROR`, `FINAL_INVALID`,
`TIMEOUT`, `SMOKE_TOOL_USED`, and `SMOKE_CLAIM_INVALID`.

Run the focused protocol tests with:

```bash
python3 -m unittest -v tests.test_agy_delegate
```

Packets are capped at 4096 UTF-8 bytes and combined output at 1 MiB.
Result must be the final event. Protocol errors, excess output and timeouts stop
the child process group. Additional failure classes: `PACKET_TOO_LARGE`,
`OUTPUT_LIMIT`, `TERMINATION_UNVERIFIED`.

The 2026-09-06 recovery reproduced boolean `enum:[false]` failure after model init with zero usage; the same schema with a plain boolean executed successfully. The wrapper now uses plain boolean schema types while post-validation still requires both flags to be exactly false. Exact runtime smoke passed with `gemini-3.8-flash-high`, `HEALTH_OK`, zero observed tool calls and nonzero usage. Revalidate the installed file in each new environment; earlier authentication failures were transient and are not schema evidence.
No minimal general-purpose Agy profile is selected: the available domain profile
is not suitable, and slash-command disabling causes loss of plan-mode control.
