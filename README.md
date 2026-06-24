# quality-ci-checks-skill

AI agent skill and templates for Python **quality gates**: Ruff (tabs), ShellCheck + shfmt, basedpyright, pip-audit, Gitleaks, and Dependabot.

This repo is the skill source — not a Python application. Install it into your coding agent, then use it to scaffold the gate into a target Python project.

## Install the skill

No clone required — installs globally via [agent-install](https://github.com/millionco/agent-install) (Cursor, Claude Code, Codex, and other supported agents):

```bash
# All supported agents
npx agent-install@latest skill add illescasDaniel/quality-ci-checks/skill/quality-ci-checks -g -y -a '*'

# Cursor
npx agent-install@latest skill add illescasDaniel/quality-ci-checks/skill/quality-ci-checks -g -y -a cursor

# Claude Code
npx agent-install@latest skill add illescasDaniel/quality-ci-checks/skill/quality-ci-checks -g -y -a claude-code
```

From a local clone while iterating:

```bash
npx agent-install@latest skill add ./skill/quality-ci-checks -g -y -a '*'
```

Upgrade — re-run the same install command.

### Uninstall

```bash
npx agent-install@latest skill remove quality-ci-checks -g -y -a '*'
npx agent-install@latest skill list -g
```

## Scaffold into a Python project

**Recommended:** with the skill installed, ask your AI agent to set up the quality gate on your project (e.g. “add the quality-ci-checks gate to this repo”). The agent follows [SKILL.md](skill/quality-ci-checks/SKILL.md), runs scaffold, merges `pyproject.toml` sections, and tailors tool config — usually better than copying files by hand.

**Manual:** you can run scaffold yourself from a clone or the installed skill path:

```bash
bash skill/quality-ci-checks/scripts/scaffold.sh /path/to/your-project
# or, after install (path varies by agent; e.g. Cursor):
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
├── checks.sh                   # shell lint + skill discovery for this repo
├── skill/quality-ci-checks/    # agent skill bundle (self-contained)
│   ├── SKILL.md
│   ├── reference.md
│   ├── quality/                # gate scripts (copied by scaffold)
│   ├── templates/
│   │   ├── pyproject-snippet.toml
│   │   ├── vscode-tasks.json
│   │   └── github/
│   └── scripts/
│       └── scaffold.sh
└── .github/workflows/
```

## Development (this repo)

```bash
./checks.sh --fix
./checks.sh
```

Lints all `*.sh` files with shfmt and shellcheck, and dry-runs [agent-install](https://github.com/millionco/agent-install) skill discovery. See [AGENTS.md](AGENTS.md).

Requires Node.js with `npx` for the skill discovery step.

## License

MIT
