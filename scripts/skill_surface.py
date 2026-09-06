#!/usr/bin/env python3
"""Read-only skill inventory and fresh-discovery manifest validation.

Python 3.11+; full YAML syntax validation uses Ruby/Psych when present and is
explicitly NOT_RUN otherwise. No package installation or skill loading occurs.
"""
import argparse
import collections
import hashlib
import json
import math
import pathlib
import re
import shutil
import subprocess

TIERS = {'CORE_ACTIVE', 'LOCAL_ON_DEMAND', 'WEB_PRIMARY', 'ARCHIVED', 'BROKEN'}


def broad_trigger(text):
    return bool(re.search(r'\b(MUST USE|ALWAYS|ANY URL|ANY response|1% chance)\b', text, re.I))


def frontmatter(text):
    parts = text.split('---', 2)
    if len(parts) != 3 or parts[0].strip():
        return {}, ['missing frontmatter']
    header = parts[1]
    keys = re.findall(r'^([\w-]+):', header, re.M)
    errors = ['duplicate key: ' + k for k, n in collections.Counter(keys).items() if n > 1]
    values = {}
    for match in re.finditer(r'^([\w-]+):[ \t]*(.*)(?:\n((?:[ \t]+[^\n]*\n?)*))?', header, re.M):
        k, value, continuation = match.groups()
        if value.strip() in {'>', '|', '>-', '|-'}:
            value = ' '.join((continuation or '').split())
        values[k] = value.strip().strip('\"\'')
    for key in ['name', 'description']:
        if not values.get(key):
            errors.append('missing ' + key)
    return values, errors


def discovery(prompt):
    data = json.loads(pathlib.Path(prompt).read_text())
    text = '\n'.join(c.get('text', '') for m in data for c in m.get('content', [])
                     if '<skills_instructions>' in c.get('text', ''))
    roots = dict(re.findall(r'- `(r\d+)` = `([^`]+)`', text))
    paths = []
    lines = []
    for line in text.splitlines():
        match = re.search(r'\(file: ([^)]+)\)', line)
        if not match:
            continue
        path = match.group(1)
        first, _, rest = path.partition('/')
        paths.append(str(pathlib.Path(roots.get(first, first)) / rest) if first in roots else path)
        lines.append(line)
    return paths, text, '\n'.join(lines)


def validate_manifest(manifest, active):
    entries = manifest.get('entries', [])
    indexed = {x['path']: x for x in entries}
    errors = []
    if len(indexed) != len(entries):
        errors.append('duplicate manifest paths')
    for row in entries:
        if row.get('tier') not in TIERS:
            errors.append('invalid tier: ' + row['path'])
    for path in active:
        if path not in indexed:
            errors.append('unclassified: ' + path)
        elif indexed[path]['tier'] != 'CORE_ACTIVE':
            errors.append('reactivated: ' + path)
    for row in entries:
        if row.get('tier') == 'CORE_ACTIVE' and row['path'] not in active:
            errors.append('missing active: ' + row['path'])
    return errors


def audit(roots, active):
    paths = set(active)
    for root in roots:
        paths.update(str(p) for p in pathlib.Path(root).rglob('SKILL.md'))
    rows = []
    headers = {}
    for path in sorted(paths):
        p = pathlib.Path(path)
        if not p.is_file():
            rows.append({'path': path, 'active': path in active, 'errors': ['missing file']})
            continue
        text = p.read_text()
        meta, errors = frontmatter(text)
        if text.startswith('---') and len(text.split('---', 2)) == 3:
            headers[path] = text.split('---', 2)[1]
        rows.append({'path': path, 'resolved_path': str(p.resolve()),
                     'name': meta.get('name'), 'description': meta.get('description'),
                     'sha256': hashlib.sha256(text.encode()).hexdigest(),
                     'bytes': len(text.encode()), 'estimated_tokens_utf8_div4': math.ceil(len(text.encode()) / 4),
                     'active': path in active, 'broad_trigger': broad_trigger(meta.get('description', '')),
                     'errors': errors})
    syntax = 'NOT_RUN: Ruby/Psych unavailable'
    if shutil.which('ruby'):
        ruby = '''require 'json'; require 'yaml'; result = {}; JSON.parse(STDIN.read).each do |p,s|
          begin; Psych.parse(s)
          rescue Exception => e; result[p] = e.message; end
        end; puts JSON.generate(result)'''
        result = subprocess.run(['ruby', '-e', ruby], input=json.dumps(headers), text=True,
                                capture_output=True, timeout=30)
        if result.returncode == 0:
            failures = json.loads(result.stdout)
            for row in rows:
                if row['path'] in failures:
                    row['errors'].append('YAML syntax: ' + failures[row['path']])
            syntax = 'Ruby/Psych syntax parser; duplicate top-level keys checked separately'
        else:
            syntax = 'NOT_RUN: Ruby/Psych failed'
    by_name = collections.defaultdict(list)
    for row in rows:
        if row.get('name') and row['active']:
            by_name[row['name']].append(row['path'])
    return {'entries': rows, 'yaml_validation': syntax,
            'inventory_count': len(rows), 'active_count': len(active),
            'invalid_inventory_count': sum(bool(x['errors']) for x in rows),
            'invalid_active_count': sum(bool(x['errors']) and x['active'] for x in rows),
            'active_broad_triggers': [x['path'] for x in rows if x['active'] and x.get('broad_trigger')],
            'active_duplicate_names': {k: v for k, v in by_name.items() if len(v) > 1}}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', action='append', default=[])
    parser.add_argument('--prompt-input', required=True, help='Fresh codex debug prompt-input JSON')
    parser.add_argument('--manifest')
    parser.add_argument('--output', required=True)
    args = parser.parse_args()
    active, whole, metadata = discovery(args.prompt_input)
    report = audit(args.root, active)
    report.update({'measurement': 'fresh Codex CLI discovery; not desktop/chat reload',
                   'skill_instruction_bytes': len(whole.encode()),
                   'active_metadata_bytes': len(metadata.encode()),
                   'active_metadata_estimated_tokens_utf8_div4': math.ceil(len(metadata.encode()) / 4),
                   'token_estimate_is_not_runtime_usage': True})
    report['manifest_errors'] = validate_manifest(json.loads(pathlib.Path(args.manifest).read_text()), active) if args.manifest else []
    pathlib.Path(args.output).write_text(json.dumps(report, indent=2, ensure_ascii=False) + '\n')
    print(json.dumps({k: v for k, v in report.items() if k != 'entries'}, ensure_ascii=False))
    return int(bool(report['manifest_errors'] or report['invalid_active_count']))


if __name__ == '__main__':
    raise SystemExit(main())
