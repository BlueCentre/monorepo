import argparse
from pathlib import Path
import importlib.util
import sys

# Dynamically load the module without executing main.
MODULE_PATH = Path(__file__).parent / 'new_project_copier.py'
spec = importlib.util.spec_from_file_location('npc', MODULE_PATH)
assert spec and spec.loader, 'Failed to load spec for new_project_copier'
mod = importlib.util.module_from_spec(spec)
sys.modules['npc'] = mod
spec.loader.exec_module(mod)  # type: ignore


def test_sanitize_project_name_basic():
    sanitize = getattr(mod, 'sanitize_project_name')
    assert sanitize('My Project') == 'my-project'
    assert sanitize('123bad') == 'p123bad'
    assert sanitize('@@@') == 'project'
    assert sanitize('good_name') == 'good_name'
    assert sanitize('multi   space') == 'multi-space'


def test_arg_parser_has_new_flags():
    build = getattr(mod, 'build_arg_parser')
    parser: argparse.ArgumentParser = build()
    help_text = parser.format_help()
    assert '--output-dir' in help_text
    assert '--dry-run' in help_text
    assert '--project-name' in help_text


def test_generate_with_conflicting_dir(tmp_path):
    # Setup a fake workspace root with required structure
    workspace = tmp_path / 'workspace'
    (workspace / 'projects' / 'template' / 'template_typer_app').mkdir(parents=True)
    # Minimal copier.yml to satisfy check
    (workspace / 'projects' / 'template' / 'template_typer_app' / 'copier.yml').write_text('project_name: {type: str}')
    gen_cls = getattr(mod, 'CopierProjectGenerator')
    gen = gen_cls(workspace)
    # Monkeypatch run_copy to simulate copier behavior
    def fake_run_copy(**kwargs):
        dst = Path(kwargs['dst_path'])
        dst.mkdir(parents=True, exist_ok=True)
        (dst / 'README.md').write_text('# Test')
        return dst
    mod.run_copy = fake_run_copy  # type: ignore
    # Pre-create directory to force conflict
    base = workspace / 'projects' / 'python'
    (base / 'sample').mkdir(parents=True, exist_ok=True)
    result = gen.generate_with_copier('python', 'cli', project_name='sample')
    assert result is not None
    assert result.name.startswith('sample-')

