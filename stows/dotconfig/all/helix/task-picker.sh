#!/usr/bin/env bash

# RUFF_OPTS=(check --select FIX --output-format concise)
RG_OPTS=(
	--line-number --no-heading --color=always --case-sensitive --trim
	-w
	'TODO:|FIXME:|BUG:|HACK:|XXX:|NOTE:'
)

function main() {
	rg "${RG_OPTS[@]}" |
		fzf --ansi \
			--prompt='search> ' \
			--header-first \
			--bind "enter:become(~/.config/helix/hx-open.sh {1} {2})" \
			--delimiter :
}

main
