# AGENTS.md

This repository is a **Cursor skill** source tree, not a Python application. Do not add `pyproject.toml`, virtualenv tooling, or Python quality gates to this repo unless explicitly asked.

## Shell checks

All `*.sh` files under this repository (including `skill/quality-ci-checks/`) must pass **shfmt** and **shellcheck**.

After editing shell scripts, run:

```bash
./checks.sh --fix
./checks.sh
```

Repeat until `./checks.sh` exits cleanly with no issues.

`--fix` applies `shfmt` formatting. In CI (`CI=true`), `--fix` is ignored and only verification runs.

## Required tools

`shellcheck` and `shfmt` must be on `PATH` (e.g. `pacman -S shellcheck shfmt`).

## Scaffold target

The full Python quality gate (`ruff`, `basedpyright`, `pip-audit`, optional `pytest`) lives in `skill/quality-ci-checks/quality/` and is copied into **target Python projects** via `skill/quality-ci-checks/scripts/scaffold.sh`. Do not run that gate against this skill repo.
