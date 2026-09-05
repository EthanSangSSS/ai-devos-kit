#!/usr/bin/env python3
"""Compare observed traces with vNext expectations without promoting mock evidence."""
import argparse
import json
from pathlib import Path

FIXTURES = Path(__file__).resolve().parents[1] / 'tests/fixtures/workflow-vnext.json'

def evaluate(cases, observations):
    results=[]
    for case in cases:
        observation=observations.get(case['id'], {})
        kind=observation.get('evidence_kind')
        facts=observation.get('facts', {})
        if kind not in ('LIVE', 'CONTRACT') or not observation.get('evidence_ref'):
            status='NOT_RUN'; mismatches=[]
        else:
            mismatches=[key for key,value in case['expected'].items()
                        if key not in facts or type(facts[key]) is not type(value) or facts[key]!=value]
            status='FAIL' if mismatches else ('PASS_RUNTIME' if kind=='LIVE' else 'PASS_CONTRACT')
        results.append({'id':case['id'],'status':status,'mismatches':mismatches,
                        'evidence_ref':observation.get('evidence_ref')})
    return results

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('observations',type=Path)
    args=parser.parse_args()
    cases=json.loads(FIXTURES.read_text())['cases']
    results=evaluate(cases,json.loads(args.observations.read_text()))
    print(json.dumps(results,indent=2))
    return 0 if all(row['status']=='PASS_RUNTIME' for row in results) else 1

if __name__=='__main__':
    raise SystemExit(main())
