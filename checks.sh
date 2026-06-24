#!/usr/bin/env bash

set -euo pipefail

# Shell lint for this skill repo — shfmt + shellcheck on all *.sh files.

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
