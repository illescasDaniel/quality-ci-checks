---
name: quality-ci-checks
description: >-
  Set up Python quality gates with Ruff (tabs), ShellCheck, shfmt, basedpyright,
  Gitleaks, and Dependabot. Use when adding checks.sh, CI workflows, linting,
  type checking, secret scanning, or when the user mentions quality gate, ruff,
  basedpyright, shellcheck, gitleaks, or dependabot for Python projects.
---

# quality-ci-checks

Scaffold and maintain a Python quality gate: **Ruff** → **ShellCheck + shfmt** → **basedpyright**, plus **Gitleaks** and **Dependabot** in CI.

## Prerequisites

Clone this repo and install the skill:

```bash
bash skill/quality-ci-checks/scripts/install.sh
```

Install records the clone path so scaffold works from `~/.cursor/skills/quality-ci-checks` afterward. Override with `QUALITY_CI_CHECKS_REPO` if needed.

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

This copies:

- `scripts/quality/` (checks.sh, ruff, shellcheck, pyright, gate helpers)
- `.github/workflows/ci.yml` and `gitleaks.yml` (if missing)
- `.github/dependabot.yml` (if missing)
- `.vscode/tasks.json` (if missing)

Then **merge** `[tool.ruff]`, `[tool.basedpyright]`, and `[project.optional-dependencies].dev` from [templates/pyproject-snippet.toml](templates/pyproject-snippet.toml). Match `pythonVersion` / `target-version` to the project's `requires-python`.

## Quality gate steps

| Step | Tool | What it checks |
|------|------|----------------|
| 1 | Ruff | Lint (`F`, `I`, `E`, `S`, `B`) + format (tabs, line-length 120) on `src/` and `tests/` |
| 2 | Shell | shfmt + ShellCheck on all `*.sh` |
| 3 | basedpyright | Strict type check on `src/` and `tests/` |

```bash
./scripts/quality/checks.sh --fix   # local autofix (ignored in CI)
./scripts/quality/checks.sh         # verify clean
```

`lib_ruff_targets` in `scripts/quality/internal/lib.sh` uses `src/` and `tests/` when present, else `scripts/quality/internal` (for tool-only repos).

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

## Additional resources

- Full pyproject snippet: [templates/pyproject-snippet.toml](templates/pyproject-snippet.toml)
- Detailed reference: [reference.md](reference.md)
