#######################################################
# CUSTOM SHELL FUNCTIONS
#######################################################
source "$HOME"/.config/zsh/plugin.zsh
source "$HOME"/.config/zsh/transient-prompt.zsh

function refresh() {
  echo "refreshing shell..."
  source "$HOME/.zshrc"
}

#######################################################
#  INITIALIZATION
#######################################################
export SHELL=zsh

#######################################################
# PROMPT
#######################################################
# autoload -Uz promptinit
# promptinit
# prompt adam1

#######################################################
# COLORS
#######################################################
autoload -Uz colors && colors
source "$HOME"/.config/shells/colors

#######################################################
# KEY BINDING / LINE EDITING
#######################################################
# Use emacs keybindings even if our EDITOR is set to vi
unsetopt BEEP
setopt interactive_comments
stty stop undef
bindkey -e

#######################################################
# HISTORY
#######################################################
# Keep 1000 lines of history within the shell and
# save it to ~/.zsh_history:
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt share_history
setopt hist_verify
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

#######################################################
# ENVIRONMENT
#######################################################
source "$HOME"/.config/shells/environ
source "$HOME"/.config/shells/tokens

#######################################################
# ZSH COMPLETIONS
#######################################################
setopt menucomplete
autoload -Uz compinit #&& compinit
zstyle ':completion:*' menu select
zle_highlight=('paste:none')
# eval "$(/home/gilles/DEVELOPPEMENT/REPOS/tomlraider/.venv/bin/tomlraider --completion zsh)"
eval "$(uv generate-shell-completion zsh)"
eval "$(uvx --generate-shell-completion zsh)"
eval "$(pixi completion --shell zsh)"
[ -s "/home/gilles/.bun/_bun" ] && source "/home/gilles/.bun/_bun"

######################################################
# PLUGINS
######################################################
eval "$(starship init zsh)"
source <(fzf --zsh)
eval "$(zoxide init zsh --hook pwd)"
eval "$(atuin init zsh --disable-up-arrow)"

# fzf-help
source /usr/local/share/fzf-help/fzf-help.zsh
zle -N fzf-help-widget
bindkey "^H" fzf-help-widget

plugins=(
  romkatv/zsh-defer
  zsh-users/zsh-completions
  # multirious/zsh-helix-mode
  zdharma-continuum/fast-syntax-highlighting
  zsh-users/zsh-history-substring-search
  zsh-users/zsh-autosuggestions
)
plugin::load $plugins

## for zsh-helix
# fzf keybinding should be done before sourcing this plugin
# ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(
#   zhm_history_prev
#   zhm_history_next
#   zhm_prompt_accept
#   zhm_accept
#   zhm_accept_or_insert_newline
# )
# ZSH_AUTOSUGGEST_ACCEPT_WIDGETS+=(
#   zhm_move_right
# )
# ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS+=(
#   zhm_move_next_word_start
#   zhm_move_next_word_end
# )
# zhm-add-update-region-highlight-hook
##

######################################################
# ALIASES
######################################################
source "$HOME"/.config/shells/alias
