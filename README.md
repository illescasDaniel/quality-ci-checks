# quality-ci-checks-skill

Cursor skill and templates for Python **quality gates**: Ruff (tabs), ShellCheck + shfmt, basedpyright, Gitleaks, and Dependabot.

Dogfoods its own `scripts/quality/checks.sh` in CI.

## Install the skill

```bash
git clone https://github.com/illescasDaniel/quality-ci-checks-skill.git
cd quality-ci-checks-skill
bash skill/quality-ci-checks/scripts/install.sh
```

Copies the skill to `~/.cursor/skills/quality-ci-checks` and records the clone path for scaffold.

## Scaffold into a Python project

From the clone or the installed skill:

```bash
bash skill/quality-ci-checks/scripts/scaffold.sh /path/to/your-project
# or:
bash ~/.cursor/skills/quality-ci-checks/scripts/scaffold.sh /path/to/your-project
```

Then merge tool sections from [`skill/quality-ci-checks/templates/pyproject-snippet.toml`](skill/quality-ci-checks/templates/pyproject-snippet.toml) into the target `pyproject.toml`.

## Quality gate

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

## CI

- **`.github/workflows/ci.yml`** — runs `checks.sh` on push/PR
- **`.github/workflows/gitleaks.yml`** — secret scanning
- **`.github/dependabot.yml`** — weekly pip and GitHub Actions updates

## Structure

```
quality-ci-checks-skill/
├── scripts/quality/              # quality gate (copied by scaffold)
├── skill/quality-ci-checks/      # Cursor skill
│   ├── SKILL.md
│   ├── reference.md
│   ├── templates/
│   │   └── pyproject-snippet.toml
│   └── scripts/
│       ├── install.sh
│       ├── scaffold.sh
│       └── repo.sh
└── .github/workflows/
```

## License

MIT
