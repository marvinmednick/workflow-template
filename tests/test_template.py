"""Checks for the template itself: scripts parse, the manifest resolves, and setup.sh produces a
project whose links all verify."""
import pathlib
import re
import subprocess

ROOT = pathlib.Path(__file__).resolve().parent.parent
SCRIPTS = sorted(p for p in (ROOT / "scripts").iterdir() if p.is_file())
STUBS = sorted((ROOT / "claude-stubs").glob("*.md"))


def run(cmd, cwd=ROOT):
    return subprocess.run(cmd, cwd=cwd, capture_output=True, text=True)


def test_scripts_parse():
    bad = [p.name for p in SCRIPTS if run(["bash", "-n", str(p)]).returncode != 0]
    assert not bad, f"bash -n fails: {bad}"


def test_every_stub_names_an_existing_command():
    missing = []
    for stub in STUBS:
        m = re.search(r"commands/([A-Za-z0-9_-]+\.md)", stub.read_text())
        if not m or not (ROOT / "commands" / m.group(1)).is_file():
            missing.append(stub.name)
    assert not missing, f"stubs naming no real commands/ file: {missing}"


def test_codex_skills_match_stubs():
    r = run([str(ROOT / "scripts" / "gen-codex-skills.sh"), "--check"])
    assert r.returncode == 0, r.stdout + r.stderr


def test_setup_creates_a_project_that_verifies(tmp_path):
    r = run(["bash", str(ROOT / "scripts" / "setup.sh")], cwd=tmp_path)
    assert r.returncode == 0, r.stdout + r.stderr
    r = run([str(tmp_path / "verify-links")], cwd=tmp_path)
    assert r.returncode == 0, r.stdout + r.stderr
