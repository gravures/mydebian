# transient-prompt.zsh
# https://github.com/starship/starship/pull/4205

zle-line-init() {
  emulate -L zsh

  [[ $CONTEXT == start ]] || return 0

  while true; do
    zle .recursive-edit
    local -i ret=$?
    [[ $ret == 0 && $KEYS == $'\4' ]] || break
    [[ -o ignore_eof ]] || exit 0
  done

  local saved_prompt=$PROMPT
  local saved_rprompt=$RPROMPT

  # Set prompt value from character module
  NEWLINE=$'\n'
  # NEWLINE=$'${(r:$COLUMNS::\u2500:)}\n'
  PROMPT="${NEWLINE}$(starship module character)"
  RPROMPT=''
  zle .reset-prompt
  PROMPT=$saved_prompt
  RPROMPT=$saved_rprompt

  if ((ret)); then
    zle .send-break
  else
    zle .accept-line
  fi
  return ret
}

zle -N zle-line-init
