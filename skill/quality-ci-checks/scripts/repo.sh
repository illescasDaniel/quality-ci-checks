#!/usr/bin/env bash
# Resolve quality-ci-checks-skill repo root for install/scaffold scripts.

quality_ci_checks_repo_root() {
	local script_dir="$1"
	local skill_root candidate repo_file

	if [[ -n "${QUALITY_CI_CHECKS_REPO:-}" ]]; then
		echo "${QUALITY_CI_CHECKS_REPO}"
		return 0
	fi

	skill_root="$(cd "${script_dir}/.." && pwd)"
	repo_file="${skill_root}/.source-repo"
	if [[ -f "${repo_file}" ]]; then
		candidate="$(<"${repo_file}")"
		if [[ -f "${candidate}/pyproject.toml" && -d "${candidate}/scripts/quality" ]]; then
			echo "${candidate}"
			return 0
		fi
	fi

	candidate="$(cd "${script_dir}/../../.." && pwd)"
	if [[ -f "${candidate}/pyproject.toml" && -d "${candidate}/scripts/quality" ]]; then
		echo "${candidate}"
		return 0
	fi

	return 1
}

quality_ci_checks_repo_or_die() {
	local script_dir="$1"
	local repo

	if repo="$(quality_ci_checks_repo_root "${script_dir}")"; then
		echo "${repo}"
		return 0
	fi

	echo "Could not find quality-ci-checks-skill repo root." >&2
	echo "Run install from a clone, set QUALITY_CI_CHECKS_REPO, or reinstall the skill." >&2
	return 1
}
