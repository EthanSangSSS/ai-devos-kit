import importlib.util
import pathlib
import unittest

SCRIPT = pathlib.Path(__file__).resolve().parents[1] / 'scripts/skill_surface.py'


class SkillSurfaceTests(unittest.TestCase):
    def setUp(self):
        spec = importlib.util.spec_from_file_location('skill_surface', SCRIPT)
        self.module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(self.module)

    def test_duplicate_keys_are_rejected(self):
        _, errors = self.module.frontmatter('---\nname: test\ndescription: Fine\nname: other\n---\nBody')
        self.assertIn('duplicate key: name', errors)

    def test_missing_description_is_rejected(self):
        _, errors = self.module.frontmatter('---\nname: test\n---\nBody')
        self.assertIn('missing description', errors)

    def test_broad_trigger_detected(self):
        self.assertTrue(self.module.broad_trigger('MUST USE for ANY URL'))
        self.assertFalse(self.module.broad_trigger('Inspect an explicitly selected iOS icon catalog.'))

    def test_reactivation_is_a_failure(self):
        expected = {'entries': [{'path': '/a/SKILL.md', 'tier': 'WEB_PRIMARY', 'sha256': 'one'}]}
        self.assertIn('reactivated: /a/SKILL.md', self.module.validate_manifest(expected, ['/a/SKILL.md']))

    def test_unclassified_active_skill_is_a_failure(self):
        self.assertIn('unclassified: /new/SKILL.md', self.module.validate_manifest({'entries': []}, ['/new/SKILL.md']))


if __name__ == '__main__':
    unittest.main()
