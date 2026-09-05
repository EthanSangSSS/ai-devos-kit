import importlib.util
import json
from pathlib import Path
import unittest

class DelegateTests(unittest.TestCase):
    def setUp(self):
        spec=importlib.util.spec_from_file_location('delegate',Path(__file__).resolve().parents[1]/'scripts/agy_delegate.py')
        self.m=importlib.util.module_from_spec(spec);spec.loader.exec_module(self.m)
    def events(self):
        return [{'event':'init','init':{'model':'gemini-3.8-flash-high','cwd':'/task','tools':[]}}, {'event':'result','result':{'status':'SUCCESS','structured_output':{'claim':'HEALTH_OK','changed_paths':[],'validation':[],'risks':[],'pushed':False,'pr_mutated':False},'usage':{'input_tokens':12}}}]
    def test_exact_model_and_workspace(self):
        events=self.events();events[0]['init']['model']='other'
        with self.assertRaisesRegex(ValueError,'MODEL_MISMATCH'):self.m.validate_event(events[0],'/task')
        events=self.events();events[0]['init']['cwd']='/other'
        with self.assertRaisesRegex(ValueError,'WORKSPACE_MISMATCH'):self.m.validate_event(events[0],'/task')
    def test_duplicate_identity_is_rejected(self):
        e=self.events()
        with self.assertRaisesRegex(ValueError,'PROTOCOL'):self.m.summarize([e[0],e[0],e[1]],'/task',0)
    def test_nonzero_cannot_pass(self):
        with self.assertRaisesRegex(ValueError,'CLI_NONZERO'):self.m.summarize(self.events(),'/task',1)
    def test_structured_remote_write_claim_rejected(self):
        e=self.events();e[1]['result']['structured_output']['pushed']=True
        with self.assertRaisesRegex(ValueError,'FINAL_INVALID'):self.m.summarize(e,'/task',0)
    def test_mode_preserved(self):
        cmd=self.m.command();self.assertNotIn('--disable-slash-commands',cmd);self.assertNotIn('--agent',cmd)
        self.assertEqual('plan',cmd[cmd.index('--mode')+1])
    def test_claim_is_not_enforcement(self):
        result=self.m.summarize(self.events(),'/task',0)
        self.assertEqual('UNVERIFIED',result['enforcement']['remote_write_denial'])
        self.assertEqual('CLAIMED',result['acceptance'])

    def test_event_order_is_protocol_checked(self):
        events=self.events()
        with self.assertRaisesRegex(ValueError,'PROTOCOL'):
            self.m.summarize([events[1],events[0]],'/task',0)

    def test_fixed_final_schema_rejects_extra_property_and_wrong_list_type(self):
        events=self.events()
        events[1]['result']['structured_output']['unexpected']='value'
        with self.assertRaisesRegex(ValueError,'FINAL_INVALID'):
            self.m.summarize(events,'/task',0)
        events=self.events()
        events[1]['result']['structured_output']['changed_paths']='file.py'
        with self.assertRaisesRegex(ValueError,'FINAL_INVALID'):
            self.m.summarize(events,'/task',0)

    def test_command_pins_fixed_schema_without_profile_or_slash_disable(self):
        cmd=self.m.command()
        schema=cmd[cmd.index('--json-schema')+1]
        self.assertEqual(self.m.EXPECTED_MODEL,cmd[cmd.index('--model')+1])
        self.assertEqual('high',cmd[cmd.index('--effort')+1])
        self.assertEqual('stream-json',cmd[cmd.index('--output-format')+1])
        self.assertEqual('stream-json',cmd[cmd.index('--input-format')+1])
        self.assertFalse(json.loads(schema)['additionalProperties'])
        self.assertNotIn('--disable-slash-commands',cmd)
        self.assertNotIn('--agent',cmd)

    def test_normal_packet_requires_scope_and_rejects_sensitive_paths(self):
        packet=self.m.build_packet('run focused checks', ['scripts/agy_delegate.py'], 'local test only')
        self.assertIn('Allowed scope:',packet)
        with self.assertRaisesRegex(ValueError,'PACKET_INVALID'):
            self.m.build_packet('run focused checks', [], 'local test only')
        with self.assertRaisesRegex(ValueError,'PACKET_UNSAFE'):
            self.m.build_packet('read .env', ['.env'], 'local read')

    def test_events_after_result_are_rejected(self):
        with self.assertRaisesRegex(ValueError, 'PROTOCOL'):
            self.m.summarize(self.events()+[{'event':'step_update'}], '/task', 0)

    def test_packet_size_and_sensitive_variants(self):
        with self.assertRaisesRegex(ValueError, 'PACKET_TOO_LARGE'):
            self.m.build_input_event('a'*9000)
        for path in ('.env.production', '../private.txt', '/etc/passwd', '.ssh/id_ed25519'):
            with self.subTest(path=path), self.assertRaisesRegex(ValueError, 'PACKET_UNSAFE'):
                self.m.build_packet('inspect', [path], 'local read')

    def test_real_child_wrong_model_is_terminated(self):
        import subprocess, sys, time
        child=subprocess.Popen([sys.executable,'-c',
            'import json,time; print(json.dumps({"event":"init","init":{"model":"wrong","cwd":"/task"}}),flush=True); time.sleep(20)'],
            stdout=subprocess.PIPE,stderr=subprocess.PIPE,start_new_session=True)
        start=time.monotonic()
        events, errors, error, timed_out, warnings=self.m._collect(child,'/task',2)
        self.assertEqual('MODEL_MISMATCH',error.classification)
        self.assertIsNotNone(child.poll());self.assertLess(time.monotonic()-start,4)
        child.stdout.close();child.stderr.close()

    def test_real_child_timeout_and_output_cap(self):
        import subprocess, sys, time
        for source, expected in [('import time; time.sleep(20)','TIMEOUT'),
                ('import sys; sys.stdout.write("x"*2000000); sys.stdout.flush()','OUTPUT_LIMIT')]:
            child=subprocess.Popen([sys.executable,'-c',source],stdout=subprocess.PIPE,stderr=subprocess.PIPE,start_new_session=True)
            events, errors, error, timed_out, warnings=self.m._collect(child,'/task',0.5)
            self.assertEqual(expected,error.classification)
            self.assertIsNotNone(child.poll())
            child.stdout.close();child.stderr.close()
