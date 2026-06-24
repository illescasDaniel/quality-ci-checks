#!/usr/bin/env bash

set -euo pipefail

# Shell lint for this skill repo — shfmt + shellcheck on all *.sh files,
# plus agent-install skill discovery dry-run.

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
skill_dir="${repo_root}/skill/quality-ci-checks"
skill_name="quality-ci-checks"
published_skill="illescasDaniel/quality-ci-checks/skill/quality-ci-checks"

FIX=false
for arg in "$@"; do
	case "${arg}" in
	--fix)
		FIX=true
		;;
	esac
done

if [[ "${CI:-}" == "true" && "${FIX}" == true ]]; then
	echo "note: --fix ignored in CI (check-only mode)"
	FIX=false
fi

missing=()
command -v shellcheck >/dev/null 2>&1 || missing+=("shellcheck")
command -v shfmt >/dev/null 2>&1 || missing+=("shfmt")
if [[ "${#missing[@]}" -gt 0 ]]; then
	echo "Missing shell tools: ${missing[*]}" >&2
	echo "Install shellcheck and shfmt via your package manager (e.g. pacman -S shellcheck shfmt)." >&2
	exit 1
fi

mapfile -t SHELL_TARGETS < <(
	find "${repo_root}" -name "*.sh" \
		-not -path "*/.git/*" \
		-not -path "*/.venv/*" \
		| sort
)

if [[ ${#SHELL_TARGETS[@]} -eq 0 ]]; then
	echo "No shell scripts found under ${repo_root}"
	exit 0
fi

echo "Checking ${#SHELL_TARGETS[@]} shell script(s)..."

if [[ "${FIX}" == true ]]; then
	shfmt -i 0 -bn -w "${SHELL_TARGETS[@]}"
fi

shfmt -i 0 -bn -d "${SHELL_TARGETS[@]}"
shellcheck -S warning "${SHELL_TARGETS[@]}"

echo "Shell checks passed."

assert_skill_listable() {
	local source="$1"
	local label="$2"
	local output

	if ! output="$(npx agent-install@latest skill add "${source}" -l -y 2>&1)"; then
		echo "${label}: agent-install skill list failed" >&2
		printf '%s\n' "${output}" >&2
		return 1
	fi

	if ! printf '%s\n' "${output}" | grep -q "${skill_name}"; then
		echo "${label}: skill list did not include ${skill_name}" >&2
		printf '%s\n' "${output}" >&2
		return 1
	fi

	printf '%s\n' "${output}"
}

if ! command -v npx >/dev/null 2>&1; then
	echo "Missing npx (install Node.js) for skill discovery check." >&2
	exit 1
fi

if [[ ! -f "${skill_dir}/SKILL.md" ]]; then
	echo "Missing skill bundle: ${skill_dir}/SKILL.md" >&2
	exit 1
fi

echo "Checking local skill source..."
assert_skill_listable "${skill_dir}" "local skill"

if [[ "${CI:-}" == "true" ]]; then
	echo "Skipping published GitHub skill source in CI (validates local checkout only)."
else
	echo "Checking published GitHub skill source..."
	assert_skill_listable "${published_skill}" "published skill"
fi

echo "Skill discovery checks passed."
