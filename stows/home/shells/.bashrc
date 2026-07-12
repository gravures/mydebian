#!/usr/bin/env bash
# shellcheck disable=SC1091

######################################################
#  FUNCTIONS LOADS
######################################################
# source /usr/local/lib/bashlib/shell.sh
function shell::interactive() {
	[[ -t 0 || -p /dev/stdin ]]
}

# Source ~/.bashrc in the current interactive shell.
function refresh() {
	if shell::interactive; then
		echo "refreshing shell..."
		source "$HOME/.bashrc"
	fi
}

# Allow yazi to cd the shell when qutting
function yazicd() {
	local tmp
	tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd "$cwd" || return 1
	fi
	rm -f "$tmp"
}

######################################################
#  INITIALIZATION
######################################################
# Source global definitions
if [ -f /etc/bashrc ]; then
	# shellcheck source=/dev/null
	source /etc/bashrc
fi
# Loads larger font on tty
# shell::bigfont
# Early loading ble.sh
# shellcheck source=/dev/null
source /usr/local/share/blesh/ble.sh --noattach

#######################################################
# COLORS
#######################################################
# shellcheck source=/dev/null
source "$HOME"/.config/shells/colors

#######################################################
# KEY BINDING / LINE EDITING
#######################################################
# Disable the bell
if shell::interactive; then
	bind "set bell-style visible"
fi
# Check the window size after each command and,
# if necessary, update the values of LINES and COLUMNS
shopt -s checkwinsize

#######################################################
# HISTORY
#######################################################
export HISTFILESIZE=10000
export HISTSIZE=1000
# Don't put duplicate lines in the history
# and do not add lines that start with a space
export HISTCONTROL=erasedups:ignoredups:ignorespace
# Causes bash to append to history instead of
# overwriting it so if you start a new terminal,
# you have old session history
shopt -s histappend
PROMPT_COMMAND='history -a'
# Allow ctrl-S for history navigation (with ctrl-R)
[[ $- == *i* ]] && stty -ixon

#######################################################
# ENVIRONMENT
#######################################################
# shellcheck source=/dev/null
source "$HOME"/.config/shells/environ
# shellcheck source=/dev/null
source "$HOME"/.config/shells/tokens

#######################################################
# BASH COMPLETIONS
#######################################################
# Show auto-completion list automatically,
# without double tab
if shell::interactive; then
	bind "set show-all-if-ambiguous On"
fi
# Ignore case on auto-completion
# Note: bind used instead of sticking
#       these in .inputrc
if shell::interactive; then
	bind "set completion-ignore-case on"
fi
# Enable bash programmable completion
# features in interactive shells
if [ -f /usr/share/bash-completion/bash_completion ]; then
	# shellcheck source=/dev/null
	source /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
	# shellcheck source=/dev/null
	source /etc/bash_completion
fi
# loads specific completions
eval "$(uv --generate-shell-completion bash)"
eval "$(uvx --generate-shell-completion bash)"
eval "$(pixi completion --shell bash)"
# eval "$(/home/gilles/DEVELOPPEMENT/REPOS/tomlraider/.venv/bin/tomlraider --completion bash)"

#######################################################
# PLUGINS
#######################################################

# BLESH If we want to combine fzf-completion with
# bash_completion, we need to load bash_completion
# earilier than fzf-completion. This is required
# regardless of whether to use ble.sh or not.
_ble_contrib_fzf_base=/usr/share/bash-completion/completions
# ble-import -d integration/fzf-completion
# ble-import -d integration/fzf-key-bindings

# prompt
eval "$(starship init bash)"

# Set up fzf key bindings and fuzzy completion
# eval "$(fzf --bash)"

# !! could mess up with starfish
eval "$(zoxide init bash --hook pwd)"

# fzf-help
# shellcheck source=/dev/null
# source /usr/local/share/fzf-help/fzf-help.bash
# bind -x '"\C-h": fzf-help-widget'

# Atuin
eval "$(atuin init bash --disable-up-arrow)"

######################################################
# ALIASES
######################################################
# shellcheck source=/dev/null
source "$HOME"/.config/shells/alias

######################################################
[[ ${BLE_VERSION-} ]] && ble-attach
