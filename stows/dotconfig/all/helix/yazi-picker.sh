#!/usr/bin/env bash

paths=$(env HELIX=1 yazi --chooser-file=/dev/stdout)

if [[ -n "$paths" ]]; then
	~/.config/helix/hx-open.sh "${paths}"
fi
