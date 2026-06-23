#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
# shellcheck source=skill/quality-ci-checks/scripts/repo.sh
source "${SCRIPT_DIR}/repo.sh"

REPO="$(quality_ci_checks_repo_or_die "${SCRIPT_DIR}")"
TEMPLATE="${SKILL_ROOT}/templates/pyproject-snippet.toml"

TARGET="${1:-.}"
TARGET="$(cd "${TARGET}" && pwd)"

if [[ ! -f "${TARGET}/pyproject.toml" ]]; then
	echo "Target must contain pyproject.toml: ${TARGET}" >&2
	exit 1
fi

if [[ ! -f "${TEMPLATE}" ]]; then
	echo "Missing template: ${TEMPLATE}" >&2
	exit 1
fi

echo "Scaffolding quality gate into: ${TARGET}"

copy_if_missing() {
	local src="$1"
	local dst="$2"
	if [[ -e "${dst}" ]]; then
		echo "  skip (exists): ${dst}"
	else
		mkdir -p "$(dirname "${dst}")"
		cp "${src}" "${dst}"
		echo "  added: ${dst}"
	fi
}

rm -rf "${TARGET}/scripts/quality"
cp -r "${REPO}/scripts/quality" "${TARGET}/scripts/"
echo "  replaced: ${TARGET}/scripts/quality/"

copy_if_missing "${REPO}/.github/workflows/ci.yml" "${TARGET}/.github/workflows/ci.yml"
copy_if_missing "${REPO}/.github/workflows/gitleaks.yml" "${TARGET}/.github/workflows/gitleaks.yml"
copy_if_missing "${REPO}/.github/dependabot.yml" "${TARGET}/.github/dependabot.yml"
copy_if_missing "${REPO}/.vscode/tasks.json" "${TARGET}/.vscode/tasks.json"

if ! grep -q '\.ruff_cache/' "${TARGET}/.gitignore" 2>/dev/null; then
	{
		echo ""
		echo ".ruff_cache/"
		echo ".mypy_cache/"
		echo ".basedpyright/"
	} >>"${TARGET}/.gitignore"
	echo "  appended quality caches to .gitignore"
fi

echo
echo "Next steps:"
echo "  1. Merge tool sections from: ${TEMPLATE}"
echo "  2. python -m venv .venv && pip install -e \".[dev]\""
echo "  3. ./scripts/quality/checks.sh --fix"
echo "  4. ./scripts/quality/checks.sh"
