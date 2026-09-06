import importlib.util
import json
from pathlib import Path
import unittest

ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('trace',ROOT/'scripts/validate_workflow_trace.py')
trace=importlib.util.module_from_spec(spec);spec.loader.exec_module(trace)

class TraceTests(unittest.TestCase):
    def setUp(self):
        self.case={'id':'R1','expected':{'delegates':0,'approval':False}}
    def test_all_twelve_distinct_scenarios_are_present(self):
        cases=json.loads(trace.FIXTURES.read_text())['cases']
        self.assertEqual([f'R{i}' for i in range(1,13)],[c['id'] for c in cases])
        self.assertTrue(all(c['expected'] and c['scenario'] for c in cases))
    def test_missing_evidence_and_claims_cannot_pass(self):
        for observation in ({},{'evidence_kind':'CLAIM','facts':self.case['expected'],'evidence_ref':'report'}):
            self.assertEqual('NOT_RUN',trace.evaluate([self.case],{'R1':observation})[0]['status'])
    def test_contract_evidence_is_not_runtime_acceptance(self):
        row=trace.evaluate([self.case],{'R1':{'evidence_kind':'CONTRACT','evidence_ref':'fixture','facts':self.case['expected']}})[0]
        self.assertEqual('PASS_CONTRACT',row['status'])
    def test_wrong_types_or_missing_fields_fail(self):
        for facts in ({'delegates':False,'approval':False},{'delegates':0}):
            row=trace.evaluate([self.case],{'R1':{'evidence_kind':'LIVE','evidence_ref':'trace','facts':facts}})[0]
            self.assertEqual('FAIL',row['status'])
