"""Regression checks for the F2.1 project-rules split."""
import pathlib
import subprocess

ROOT = pathlib.Path(__file__).resolve().parent.parent


def read(path):
    return (ROOT / path).read_text()


def test_agents_template_has_no_project_sections():
    content = read("skeleton/AGENTS-template.md")
    forbidden = (
        "Project-Specific Architecture Boundaries",
        "PROJECT-SPECIFIC",
        "it.skip",
        "describe.skip",
        "jest.",
    )
    assert not [token for token in forbidden if token in content]


def test_agents_template_requires_project_file_with_precedence():
    content = read("skeleton/AGENTS-template.md")
    section = content.split("## Project-Specific Rules\n", 1)[1].split("## ", 1)[0]
    assert "PROJECT_AGENTS.md" in section
    assert "Read `PROJECT_AGENTS.md` in full" in section
    assert "Review Ledger Protocol" in section
    assert "Checks Are Not Yours To Change" in section


def test_agents_template_keeps_shared_test_rules():
    content = read("skeleton/AGENTS-template.md")
    for phrase in (
        "Every test must be able to fail",
        "Write every test the spec or plan names",
        "No stand-in data",
        "Run the project gate",
    ):
        assert phrase in content


def test_project_agents_template_has_required_sections():
    content = read("skeleton/PROJECT_AGENTS-template.md")
    for heading in (
        "## Architecture boundaries",
        "## Coding rules for this stack",
        "## Test rules for this stack",
        "## Add-ons",
    ):
        assert heading in content


def test_no_old_project_agent_name_outside_history():
    old_name = "PROJECT_" + "AGENT.md"
    excluded = {
        "CHANGELOG.md",
        "specs/F2-project-rules-split.md",
        "tests/test_f2_skeleton.py",
    }
    files = subprocess.run(
        ["git", "ls-files", "--cached", "--others", "--exclude-standard"],
        cwd=ROOT,
        check=True,
        capture_output=True,
        text=True,
    ).stdout.splitlines()
    offenders = []
    for relative in files:
        if relative in excluded or relative.startswith("plans/"):
            continue
        if not (ROOT / relative).is_file():
            continue
        if old_name in (ROOT / relative).read_text():
            offenders.append(relative)
    assert not offenders


def test_project_file_described_as_required():
    paths = (
        "skeleton/CLAUDE-template.md",
        "skeleton/WORKFLOW-template.md",
        "CLAUDE.md",
        "WORKFLOW.md",
    )
    forbidden = ("optional", "may not exist", "if present")
    offenders = []
    for path in paths:
        for line in read(path).splitlines():
            if "PROJECT_AGENTS.md" in line and any(word in line for word in forbidden):
                offenders.append(path)
    assert not offenders


def test_root_agents_matches_skeleton_and_root_project_file_has_rules():
    assert read("AGENTS.md") == read("skeleton/AGENTS-template.md")
    content = read("PROJECT_AGENTS.md")
    assert "CHANGELOG" in content
    assert "VERSION" in content
    assert "upgrade-workflow" in content
