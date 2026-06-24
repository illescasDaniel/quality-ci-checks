#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_SRC="$(cd "${SCRIPT_DIR}/.." && pwd)"
SKILL_DST="${HOME}/.cursor/skills/quality-ci-checks"

if [[ ! -f "${SKILL_SRC}/SKILL.md" ]]; then
	echo "Missing SKILL.md in ${SKILL_SRC}" >&2
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

echo
echo "Done."
echo "  Skill: ${SKILL_DST}"
echo
echo "Scaffold a Python project:"
echo "  bash ${SKILL_DST}/scripts/scaffold.sh /path/to/project"
