#!/usr/bin/env bash

function open() {
	local file=${1}
	local line=${2:-'0'}

	# tmux last-window
	tmux send-keys Escape
	tmux send-keys Escape
	tmux send-keys ":o $file"
	tmux send-keys Enter
	tmux send-keys Escape
	tmux send-keys Escape
	tmux send-keys ":goto ${line}"
	tmux send-keys Enter
}

open "${@}"
