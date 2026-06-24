---
name: quality-ci-checks
description: >-
  Set up Python quality gates with Ruff (tabs), ShellCheck, shfmt, basedpyright,
  pip-audit, Gitleaks, and Dependabot. Use when adding checks.sh, CI workflows,
  linting, type checking, dependency audit, secret scanning, or when the user
  mentions quality gate, ruff, basedpyright, shellcheck, pip-audit, gitleaks,
  or dependabot for Python projects.
---

# quality-ci-checks

Scaffold and maintain a Python quality gate: **Ruff** → **ShellCheck + shfmt** → **basedpyright** → **pip-audit**, plus **pytest** when the project has tests, and **Gitleaks** and **Dependabot** in CI.

## Prerequisites

Clone this repo and install the skill:

```bash
bash skill/quality-ci-checks/scripts/install.sh
```

Install copies the skill to `~/.cursor/skills/quality-ci-checks`. Scaffold and install scripts resolve paths from the skill directory itself — no clone path or repo root required.

## When to use

- User wants `checks.sh`, local quality gate, or CI lint/type checks
- Bootstrapping a new Python project with Ruff (tabs), basedpyright strict, shell lint
- Adding Gitleaks secret scan or Dependabot to `.github/`

## Scaffold into a target project

From the skill repo root or the installed skill:

```bash
bash skill/quality-ci-checks/scripts/scaffold.sh /path/to/python-project
# or after install:
bash ~/.cursor/skills/quality-ci-checks/scripts/scaffold.sh /path/to/python-project
```

This copies from the skill bundle:

- `quality/` → `scripts/quality/` (checks.sh, ruff, shellcheck, pyright, pytest, pip-audit, gate helpers)
- `.github/workflows/ci.yml` and `gitleaks.yml` (if missing)
- `.github/dependabot.yml` (if missing)

`checks.sh` automatically runs the pytest step when the target project uses pytest (see below).

Then **merge** `[tool.ruff]`, `[tool.basedpyright]`, and `[project.optional-dependencies].dev` from [templates/pyproject-snippet.toml](templates/pyproject-snippet.toml). Match `pythonVersion` / `target-version` to the project's `requires-python`.

### Optional VS Code tasks

A sample [templates/vscode-tasks.json](templates/vscode-tasks.json) is available. **Do not** copy or gitignore it automatically — let the developer decide whether to use, commit, or ignore `.vscode/`.

## Quality gate steps

| Step | Tool | What it checks |
|------|------|----------------|
| 1 | Ruff | Lint (`F`, `I`, `E`, `S`, `B`) + format (tabs, line-length 120) on `src/` and `tests/` |
| 2 | Shell | shfmt + ShellCheck on all `*.sh` |
| 3 | basedpyright | Strict type check on `src/` and `tests/` |
| 4 | pip-audit | Dependency CVE scan on the project venv |
| 5 | pytest | Unit tests + coverage (when the project uses pytest) |

```bash
./scripts/quality/checks.sh --fix   # local autofix (ignored in CI)
./scripts/quality/checks.sh         # verify clean
```

`lib_ruff_targets` in `quality/internal/lib.sh` uses `src/` and `tests/` when present, else the bundled `internal/` directory (for tool-only repos).

## CI workflows

- **`ci.yml`** — venv, dev deps, shellcheck/shfmt, runs `./scripts/quality/checks.sh`
- **`gitleaks.yml`** — secret scan on push/PR (`gitleaks/gitleaks-action@v2`)
- **`dependabot.yml`** — weekly pip + github-actions updates

Adjust `python-version` in `ci.yml` to match the target project.

## Ruff defaults

- Tab indentation (`indent-style = "tab"`)
- Rules: `F`, `I`, `E`, `S`, `B`; ignore `E501`
- isort: `combine-as-imports`, `lines-after-imports = 2`
- Per-file ignores: `scripts/**` → `S603`, `S607`; `tests/**` → `S101`

## basedpyright defaults

- `typeCheckingMode = "strict"` on `src/` and `tests/`
- `tests/` execution environment adds `src/` to `extraPaths`
- Relaxed `reportUnknown*` and `reportAttributeAccessIssue` for third-party stubs

## After substantive changes

1. Run `./scripts/quality/checks.sh --fix` once
2. Run `./scripts/quality/checks.sh` to confirm clean
3. Fix any basedpyright errors manually (monkey-patches, missing stubs)

## Do not

- Commit secrets (Gitleaks will flag them)
- Skip merging pyproject tool sections after scaffold
- Use `--fix` in CI (`CI=true` ignores it)
- Automatically copy `.vscode/tasks.json` or modify `.gitignore` for `.vscode/` — that is each developer's choice

## Additional resources

- Full pyproject snippet: [templates/pyproject-snippet.toml](templates/pyproject-snippet.toml)
- Detailed reference: [reference.md](reference.md)
