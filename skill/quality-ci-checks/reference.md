# Quality CI Checks — Reference

## File layout after scaffold

```
project/
├── pyproject.toml          # merge skill templates/pyproject-snippet.toml sections
├── .gitignore              # .ruff_cache/, .basedpyright/, etc.
├── .github/
│   ├── dependabot.yml
│   └── workflows/
│       ├── ci.yml
│       └── gitleaks.yml
├── .vscode/tasks.json
├── scripts/quality/
│   ├── checks.sh
│   ├── ruff.sh
│   ├── shellcheck.sh
│   ├── pyright.sh
│   └── internal/
│       ├── gate.sh
│       ├── gate_emit.py
│       └── lib.sh
├── src/                    # Ruff + basedpyright target
└── tests/                  # Ruff + basedpyright target
```

## checks.sh internals

- Sources `gate.sh` for step reporting and GitHub Actions `::error` annotations
- `gate_emit.py` parses Ruff `--output-format=github` and basedpyright `--outputjson`
- `--fix` runs Ruff autofix/format and `shfmt -w`; disabled when `CI=true`

## Extending the gate

Optional steps used in larger projects (not in the default 3-step gate):

| Step | Script | Notes |
|------|--------|-------|
| pip-audit | `internal/audit_deps.sh` | Dependency CVE scan |
| pytest | `pytest.sh` | Unit tests + coverage |

Add steps by incrementing `GATE_PLANNED_STEPS` and mirroring the pattern in `checks.sh`.

## GitHub Actions permissions

- `ci.yml`: `contents: read`
- `gitleaks.yml`: `contents: read`; uses `GITHUB_TOKEN` for PR comments

## Local shell tools

ShellCheck and shfmt must be on `PATH` for the shell step. Install via package manager, e.g. `pacman -S shellcheck shfmt`.
