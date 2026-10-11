"""Behavioral checks for F2.2 project-rule loading and repository validation."""
import json
import os
import pathlib
import stat
import subprocess

import pytest


ROOT = pathlib.Path(__file__).resolve().parent.parent
TOOLS = ("codex", "claude", "gemini", "aider")


def run(command, cwd, env=None):
    return subprocess.run(command, cwd=cwd, env=env, capture_output=True, text=True)


def make_fake_tools(tmp_path):
    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()
    for name in TOOLS:
        tool = bin_dir / name
        tool.write_text(
            "#!/usr/bin/env bash\n"
            "set -u\n"
            'log="$TOOL_LOG_DIR/"$(basename "$0")\n'
            'printf "\\n--- invocation ---\\n" >> "$log"\n'
            '{\n'
            '  printf "%s\\n" "$@"\n'
            '} >> "$log"\n'
        )
        tool.chmod(tool.stat().st_mode | stat.S_IEXEC)
    return bin_dir


def make_project(tmp_path, with_rules=True, tool="codex", conf=True):
    project = tmp_path / "project"
    project.mkdir()
    (project / "plans").mkdir()
    (project / "specs").mkdir()
    if conf:
        (project / ".implement.conf").write_text(
            f"tool={tool}\nTEST_CMD=true\nSPEC_FILE_PATTERN=scripts|tests\n"
        )
    (project / "specs/F1-demo.md").write_text(
        "# Demo\n\n**Review Level:** Light\n\n"
        "Files: `scripts/demo` and `tests/test_demo.py`.\n"
    )
    if with_rules:
        (project / "PROJECT_AGENTS.md").write_text("# Project rules\n")
    return project


def run_implement(project, *args, bin_dir):
    env = os.environ.copy()
    env["PATH"] = f"{bin_dir}{os.pathsep}{env['PATH']}"
    env["TOOL_LOG_DIR"] = str(project / "tool-logs")
    (project / "tool-logs").mkdir(exist_ok=True)
    return run([str(ROOT / "scripts/implement"), *args], project, env)


def tool_invocations(project, tool):
    log = (project / "tool-logs" / tool).read_text()
    return [invocation for invocation in log.split("\n--- invocation ---\n") if invocation]


def make_repo_project(tmp_path, with_rules):
    project = tmp_path / "repo"
    project.mkdir()
    for directory in ("plans", "specs", "architecture"):
        (project / directory).mkdir()
    for filename in ("PLAN.md", "BACKLOG.md", "IDEAS.md", ".workflow-version"):
        (project / filename).write_text("test\n")
    if with_rules:
        (project / "PROJECT_AGENTS.md").write_text("# Project rules\n")

    bin_dir = tmp_path / "repo-bin"
    bin_dir.mkdir()
    gh = bin_dir / "gh"
    gh.write_text(
        "#!/usr/bin/env bash\n"
        'case "$1 $2" in\n'
        '  "auth status") exit 0;;\n'
        '  "repo view") echo workflow-template; exit 0;;\n'
        '  "label list") printf "%s\\n" feature enhancement decision-needed specced in-review cleanup test-quality docs severity:high severity:medium severity:low effort:small effort:medium effort:large; exit 0;;\n'
        "esac\n"
    )
    gh.chmod(gh.stat().st_mode | stat.S_IEXEC)
    env = os.environ.copy()
    env["PATH"] = f"{bin_dir}{os.pathsep}{env['PATH']}"
    return project, env


def test_aider_config_reads_project_agents():
    config = (ROOT / "configs/.aider.conf.yml").read_text()
    assert config.index("  - AGENTS.md") < config.index("  - PROJECT_AGENTS.md") < config.index("  - CODING.md")


def test_gemini_config_lists_project_agents():
    settings = json.loads((ROOT / "configs/.gemini/settings.json").read_text())
    assert settings["context"]["fileName"] == ["AGENTS.md", "PROJECT_AGENTS.md", "CODING.md"]


def test_implement_stops_without_project_agents(tmp_path):
    project = make_project(tmp_path, with_rules=False)
    bin_dir = make_fake_tools(tmp_path)
    result = run_implement(project, "F1", "--plan", bin_dir=bin_dir)
    assert result.returncode != 0
    assert "PROJECT_AGENTS.md" in result.stdout
    assert "PROJECT_AGENTS-template.md" in result.stdout
    assert not list((project / "tool-logs").iterdir())

    empty = tmp_path / "empty"
    empty.mkdir()
    result = run_implement(empty, "F1", "--plan", bin_dir=bin_dir)
    assert result.returncode != 0
    assert "PROJECT_AGENTS.md" in result.stdout
    assert "No tool specified" not in result.stdout


@pytest.mark.parametrize("tool", TOOLS)
@pytest.mark.parametrize("mode", ("--plan", "--implement"))
def test_implement_stop_covers_every_tool_and_mode(tmp_path, tool, mode):
    project = make_project(tmp_path, with_rules=False, tool=tool)
    bin_dir = make_fake_tools(tmp_path)
    args = ["F1", "--tool", tool]
    if mode == "--plan":
        args.append(mode)
    result = run_implement(project, *args, bin_dir=bin_dir)
    assert result.returncode != 0
    assert "PROJECT_AGENTS.md" in result.stdout
    assert not list((project / "tool-logs").iterdir())


@pytest.mark.parametrize("tool", TOOLS)
@pytest.mark.parametrize("mode", ("--plan", "--implement"))
def test_implement_runs_when_project_agents_present(tmp_path, tool, mode):
    project = make_project(tmp_path, tool=tool)
    bin_dir = make_fake_tools(tmp_path)
    args = ["F1", "--tool", tool]
    if mode == "--plan":
        args.append(mode)
    result = run_implement(project, *args, bin_dir=bin_dir)
    assert result.returncode == 0, result.stdout + result.stderr
    assert (project / "tool-logs" / tool).is_file()


def test_codex_prompts_name_project_agents(tmp_path):
    project = make_project(tmp_path)
    bin_dir = make_fake_tools(tmp_path)
    result = run_implement(project, "F1", "--tool", "codex", "--plan", bin_dir=bin_dir)
    assert result.returncode == 0, result.stdout + result.stderr
    (project / "plans/F1-plan-approved.md").write_text("# Approved\n")
    result = run_implement(project, "F1", "--tool", "codex", bin_dir=bin_dir)
    assert result.returncode == 0, result.stdout + result.stderr
    (project / "plans/F1-plan-approved.md").unlink()
    result = run_implement(project, "F1", "--tool", "codex", bin_dir=bin_dir)
    assert result.returncode == 0, result.stdout + result.stderr
    invocations = tool_invocations(project, "codex")
    assert len(invocations) == 3
    assert all("PROJECT_AGENTS.md" in invocation for invocation in invocations)


def test_claude_prompts_name_project_agents(tmp_path):
    project = make_project(tmp_path)
    bin_dir = make_fake_tools(tmp_path)
    result = run_implement(project, "F1", "--tool", "claude", "--plan", bin_dir=bin_dir)
    assert result.returncode == 0, result.stdout + result.stderr
    (project / "plans/F1-plan-approved.md").write_text("# Approved\n")
    result = run_implement(project, "F1", "--tool", "claude", bin_dir=bin_dir)
    assert result.returncode == 0, result.stdout + result.stderr
    (project / "plans/F1-plan-approved.md").unlink()
    result = run_implement(project, "F1", "--tool", "claude", bin_dir=bin_dir)
    assert result.returncode == 0, result.stdout + result.stderr
    invocations = tool_invocations(project, "claude")
    assert len(invocations) == 3
    assert all("PROJECT_AGENTS.md" in invocation for invocation in invocations)


def test_implement_header_comments_name_project_agents():
    lines = (ROOT / "scripts/implement").read_text().splitlines()
    required = ("For aider", "For Gemini CLI", "For Codex")
    for phrase in required:
        matching = [line for line in lines if phrase in line]
        assert matching and all("PROJECT_AGENTS.md" in line for line in matching)


def test_implement_command_names_project_agents():
    content = (ROOT / "commands/implement.md").read_text()
    step_zero, _ = content.split("## Step 1 — Read TEST_CMD from config", 1)
    agent_prompt = content.split("## Step 2 — Spawn the implementation agent", 1)[1]
    read_line = next(line for line in agent_prompt.splitlines() if "Read AGENTS.md" in line)
    assert "PROJECT_AGENTS.md" in read_line and "CODING.md" in read_line
    step_zero_start = step_zero.index("## Step 0 — Parse and validate")
    step_zero = step_zero[step_zero_start:]
    assert "PROJECT_AGENTS.md" in step_zero and "stop" in step_zero
    assert "PROJECT_AGENTS.md" in agent_prompt


def test_setup_next_steps_include_project_agents_cp(tmp_path):
    result = run(["bash", str(ROOT / "scripts/setup.sh")], tmp_path)
    assert result.returncode == 0, result.stdout + result.stderr
    assert "skeleton/PROJECT_AGENTS-template.md PROJECT_AGENTS.md" in result.stdout


def test_verify_repo_warns_when_project_agents_missing(tmp_path):
    project, env = make_repo_project(tmp_path, with_rules=False)
    result = run([str(ROOT / "scripts/verify-repo")], project, env)
    assert result.returncode == 0, result.stdout + result.stderr
    assert "⚠" in result.stdout and "PROJECT_AGENTS.md" in result.stdout


def test_verify_repo_quiet_when_project_agents_present(tmp_path):
    project, env = make_repo_project(tmp_path, with_rules=True)
    result = run([str(ROOT / "scripts/verify-repo")], project, env)
    assert result.returncode == 0, result.stdout + result.stderr
    assert "⚠" not in result.stdout


def test_verify_repo_real_failures_still_fail(tmp_path):
    project, env = make_repo_project(tmp_path, with_rules=False)
    (project / "PLAN.md").unlink()
    result = run([str(ROOT / "scripts/verify-repo")], project, env)
    assert result.returncode != 0
