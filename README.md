# quality-ci-checks-skill

Cursor skill and templates for Python **quality gates**: Ruff (tabs), ShellCheck + shfmt, basedpyright, pip-audit, Gitleaks, and Dependabot.

This repo is the skill source — not a Python application. Scaffold the gate into a target project to use it.

## Development (this repo)

```bash
./checks.sh --fix
./checks.sh
```

Lints all `*.sh` files with shfmt and shellcheck. See [AGENTS.md](AGENTS.md).

## Install the skill

```bash
git clone https://github.com/illescasDaniel/quality-ci-checks-skill.git
cd quality-ci-checks-skill
bash skill/quality-ci-checks/scripts/install.sh
```

Copies the self-contained skill to `~/.cursor/skills/quality-ci-checks`.

## Scaffold into a Python project

From the clone or the installed skill:

```bash
bash skill/quality-ci-checks/scripts/scaffold.sh /path/to/your-project
# or:
bash ~/.cursor/skills/quality-ci-checks/scripts/scaffold.sh /path/to/your-project
```

Then merge tool sections from [`skill/quality-ci-checks/templates/pyproject-snippet.toml`](skill/quality-ci-checks/templates/pyproject-snippet.toml) into the target `pyproject.toml`.

Optional: [`templates/vscode-tasks.json`](skill/quality-ci-checks/templates/vscode-tasks.json) for VS Code — copy manually if wanted; commit or gitignore `.vscode/` per team preference.

## Quality gate (target projects)

After scaffolding:

```bash
python -m venv .venv
source .venv/bin/activate
pip install -e ".[dev]"
./scripts/quality/checks.sh --fix
./scripts/quality/checks.sh
```

| Step | Tool |
|------|------|
| 1 | Ruff lint + format (tabs) on `src/` and `tests/` |
| 2 | ShellCheck + shfmt |
| 3 | basedpyright (strict) on `src/` and `tests/` |
| 4 | pip-audit (dependency CVE scan) |
| 5 | pytest + coverage (when the project uses pytest) |

## CI (this repo)

- **`.github/workflows/ci.yml`** — validates skill layout and runs `./checks.sh`
- **`.github/workflows/gitleaks.yml`** — secret scanning
- **`.github/dependabot.yml`** — weekly GitHub Actions updates

## Structure

```
quality-ci-checks-skill/
├── AGENTS.md
├── checks.sh                   # shell lint for this repo
├── skill/quality-ci-checks/    # Cursor skill (self-contained)
│   ├── SKILL.md
│   ├── reference.md
│   ├── quality/                # gate scripts (copied by scaffold)
│   ├── templates/
│   │   ├── pyproject-snippet.toml
│   │   ├── vscode-tasks.json
│   │   └── github/
│   └── scripts/
│       ├── install.sh
│       └── scaffold.sh
└── .github/workflows/
```

## License

MIT
