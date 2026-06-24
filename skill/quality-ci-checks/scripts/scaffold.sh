#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
QUALITY_SRC="${SKILL_ROOT}/quality"
GITHUB_SRC="${SKILL_ROOT}/templates/github"
TEMPLATE="${SKILL_ROOT}/templates/pyproject-snippet.toml"

TARGET="${1:-.}"
TARGET="$(cd "${TARGET}" && pwd)"

if [[ ! -f "${TARGET}/pyproject.toml" ]]; then
	echo "Target must contain pyproject.toml: ${TARGET}" >&2
	exit 1
fi

if [[ ! -d "${QUALITY_SRC}" ]]; then
	echo "Missing quality gate bundle: ${QUALITY_SRC}" >&2
	exit 1
fi

if [[ ! -f "${TEMPLATE}" ]]; then
	echo "Missing template: ${TEMPLATE}" >&2
	exit 1
fi

has_pytest_tests() {
	# shellcheck source=quality/internal/lib.sh
	source "${QUALITY_SRC}/internal/lib.sh"
	lib_has_pytest_tests "$1"
}

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

mkdir -p "${TARGET}/scripts"
rm -rf "${TARGET}/scripts/quality"
cp -r "${QUALITY_SRC}" "${TARGET}/scripts/quality"
echo "  replaced: ${TARGET}/scripts/quality/"

copy_if_missing "${GITHUB_SRC}/workflows/ci.yml" "${TARGET}/.github/workflows/ci.yml"
copy_if_missing "${GITHUB_SRC}/workflows/gitleaks.yml" "${TARGET}/.github/workflows/gitleaks.yml"
copy_if_missing "${GITHUB_SRC}/dependabot.yml" "${TARGET}/.github/dependabot.yml"

if ! grep -q '\.ruff_cache/' "${TARGET}/.gitignore" 2>/dev/null; then
	{
		echo ""
		echo ".ruff_cache/"
		echo ".mypy_cache/"
		echo ".basedpyright/"
	} >>"${TARGET}/.gitignore"
	echo "  appended quality caches to .gitignore"
fi

if ! grep -q '^\.coverage$' "${TARGET}/.gitignore" 2>/dev/null; then
	{
		echo ".coverage"
		echo "htmlcov/"
	} >>"${TARGET}/.gitignore"
	echo "  appended coverage artifacts to .gitignore"
fi

echo
echo "Next steps:"
echo "  1. Merge tool sections from: ${TEMPLATE}"
if has_pytest_tests "${TARGET}"; then
	echo "     (include pytest + pytest-cov in [project.optional-dependencies].dev)"
fi
echo "  2. python -m venv .venv && pip install -e \".[dev]\""
echo "  3. ./scripts/quality/checks.sh --fix"
echo "  4. ./scripts/quality/checks.sh"
echo
echo "Optional: copy ${SKILL_ROOT}/templates/vscode-tasks.json to .vscode/tasks.json"
echo "  (editor config is up to each developer — commit or gitignore as you prefer)"
