# Quality CI Checks — Reference

## Skill layout

```
skill/quality-ci-checks/
├── SKILL.md
├── reference.md
├── quality/                    # quality gate bundle (copied to target projects)
│   ├── checks.sh
│   ├── ruff.sh
│   ├── shellcheck.sh
│   ├── pyright.sh
│   ├── pytest.sh
│   └── internal/
│       ├── audit_deps.sh
│       ├── gate.sh
│       ├── gate_emit.py
│       └── lib.sh
├── templates/
│   ├── pyproject-snippet.toml
│   ├── vscode-tasks.json
│   └── github/
│       ├── dependabot.yml
│       └── workflows/
│           ├── ci.yml
│           └── gitleaks.yml
└── scripts/
    ├── install.sh
    └── scaffold.sh
```

## File layout after scaffold

```
project/
├── pyproject.toml          # merge skill templates/pyproject-snippet.toml sections
├── .gitignore              # .ruff_cache/, .basedpyright/, .coverage/, etc.
├── .github/
│   ├── dependabot.yml
│   └── workflows/
│       ├── ci.yml
│       └── gitleaks.yml
├── scripts/quality/        # copied from skill/quality-ci-checks/quality/
│   ├── checks.sh
│   ├── ruff.sh
│   ├── shellcheck.sh
│   ├── pyright.sh
│   ├── pytest.sh
│   └── internal/
├── src/                    # Ruff + basedpyright target
└── tests/                  # Ruff + basedpyright + pytest target
```

## checks.sh internals

- Sources `gate.sh` for step reporting and GitHub Actions `::error` annotations
- `gate_emit.py` parses Ruff `--output-format=github` and basedpyright `--outputjson`
- `--fix` runs Ruff autofix/format and `shfmt -w`; disabled when `CI=true`
- Step 4 always runs `internal/audit_deps.sh` (pip-audit)
- Step 5 runs `pytest.sh` when `lib_has_pytest_tests` detects pytest usage
- `lib.sh` finds the project root by walking up to `pyproject.toml`

## Pytest detection

`lib_has_pytest_tests` enables step 5 when any of the following match:

- `pytest` listed in `pyproject.toml` dependencies
- `tests/` or `test/` contains `test_*.py`, `*_test.py`, or `conftest.py`
- Python files under those dirs import pytest

Scaffold reminds you to add `pytest` and `pytest-cov` to dev dependencies when tests are detected.

## GitHub Actions permissions

- `ci.yml`: `contents: read`
- `gitleaks.yml`: `contents: read`; uses `GITHUB_TOKEN` for PR comments

## Local shell tools

ShellCheck and shfmt must be on `PATH` for the shell step. Install via package manager, e.g. `pacman -S shellcheck shfmt`.

## Optional VS Code tasks

[templates/vscode-tasks.json](templates/vscode-tasks.json) defines **Quality Gate** and **Quality Gate (fix)** tasks. Copy to `.vscode/tasks.json` if useful. Whether to commit or gitignore `.vscode/` is entirely up to each project or developer — scaffold does not touch it.
