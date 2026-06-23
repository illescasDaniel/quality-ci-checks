#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=skill/quality-ci-checks/scripts/repo.sh
source "${SCRIPT_DIR}/repo.sh"

REPO="$(quality_ci_checks_repo_or_die "${SCRIPT_DIR}")"
SKILL_SRC="${REPO}/skill/quality-ci-checks"
SKILL_DST="${HOME}/.cursor/skills/quality-ci-checks"

if [[ ! -d "${SKILL_SRC}" ]]; then
	echo "Missing skill source: ${SKILL_SRC}" >&2
	exit 1
fi

if [[ -d "${SKILL_DST}" ]]; then
	echo "Upgrading Cursor skill at: ${SKILL_DST}"
else
	echo "Installing Cursor skill to: ${SKILL_DST}"
fi

mkdir -p "${HOME}/.cursor/skills"
rm -rf "${SKILL_DST}"
cp -r "${SKILL_SRC}" "${SKILL_DST}"
printf '%s\n' "${REPO}" >"${SKILL_DST}/.source-repo"

echo
echo "Done."
echo "  Skill: ${SKILL_DST}"
echo "  Source repo: ${REPO}"
echo
echo "Scaffold a Python project:"
echo "  bash ${SKILL_DST}/scripts/scaffold.sh /path/to/project"
