"""Checks for the v34 migration procedure and release metadata."""
import os
import pathlib
import re
import subprocess


ROOT = pathlib.Path(__file__).resolve().parent.parent
COMMAND = ROOT / "commands" / "upgrade-workflow.md"


def _step_1b(text):
    start = text.index("## Step 1b")
    end = text.index("## Step 1 — Process each skeleton file change")
    return text[start:end]


def _v34_entry(text):
    start = text.index("## v34")
    end_match = re.search(r"^## v\d+", text[start + len("## v34"):], re.MULTILINE)
    end = start + len("## v34") + end_match.start() if end_match else len(text)
    return text[start:end]


def test_step_1b_sits_between_1a_and_the_skeleton_loop():
    text = COMMAND.read_text()
    assert text.index("## Step 1a") < text.index("## Step 1b") < text.index(
        "## Step 1 — Process each skeleton file change"
    )
    assert "below 34" in _step_1b(text)


def test_step_1b_says_what_moves_and_what_is_flagged():
    step = _step_1b(COMMAND.read_text())
    for phrase in (
        "Project-Specific Architecture Boundaries",
        "PROJECT-SPECIFIC",
        "pytest.skip",
        "flag",
        "never overwritten",
    ):
        assert phrase in step


def test_step_1b_requires_backup_and_approval():
    step = _step_1b(COMMAND.read_text())
    assert "AGENTS.md.bak" in step
    assert "not committed" in step
    assert "stop and ask" in step
    assert "apply only after approval" in step


def test_step_1b_points_at_the_v33_skeleton():
    step = _step_1b(COMMAND.read_text())
    assert "git -C" in step
    assert "65f1fd1:skeleton/AGENTS-template.md" in step


def test_skeleton_loop_replaces_agents_and_spares_project_file():
    text = COMMAND.read_text()
    loop = text[text.index("## Step 1 — Process each skeleton file change") :]
    assert "AGENTS.md" in loop and "replaced from the skeleton" in loop
    assert "PROJECT_AGENTS.md" in loop and "never touched" in loop
    assert "has already been customized with project-specific boundaries" not in text


def test_version_matches_top_changelog_entry():
    text = (ROOT / "CHANGELOG.md").read_text()
    first_heading = re.search(r"^## v(\d+)", text, re.MULTILINE)
    assert first_heading
    assert (ROOT / "VERSION").read_text().strip() == first_heading.group(1)


def test_changelog_v34_entry_has_required_parts():
    text = (ROOT / "CHANGELOG.md").read_text()
    entry = _v34_entry(text)
    for phrase in (
        "### Summary",
        "### What changed",
        "### What existing projects need to do",
        "PROJECT_AGENTS.md",
        "v25",
        "no project had one",
        "v35",
        "symlink",
    ):
        assert phrase in entry


def test_changelog_v34_names_every_changed_area():
    entry = _v34_entry((ROOT / "CHANGELOG.md").read_text())
    for phrase in (
        "skeleton/AGENTS-template.md",
        "skeleton/PROJECT_AGENTS-template.md",
        "scripts/implement",
        "scripts/verify-repo",
        "scripts/setup.sh",
        "configs/",
        "upgrade-workflow",
    ):
        assert phrase in entry


def test_check_workflow_flags_a_v33_project(tmp_path):
    project = tmp_path / "project"
    project.mkdir()
    version = project / ".workflow-version"
    version.write_text("33\n")
    env = {**os.environ, "WORKFLOW_TEMPLATE_DIR": str(ROOT)}
    check = ROOT / "scripts" / "check-workflow"

    behind = subprocess.run([str(check)], cwd=project, env=env, capture_output=True, text=True)
    assert behind.returncode == 1
    assert "v34" in behind.stdout

    version.write_text((ROOT / "VERSION").read_text())
    current = subprocess.run([str(check)], cwd=project, env=env, capture_output=True, text=True)
    assert current.returncode == 0
