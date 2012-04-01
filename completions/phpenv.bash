_phpenv() {
  COMPREPLY=()
  local word="${COMP_WORDS[COMP_CWORD]}"

  if [ "$COMP_CWORD" -eq 1 ]; then
    COMPREPLY=( $(compgen -W "$(phpenv commands)" -- "$word") )
  else
    local command="${COMP_WORDS[1]}"
    local completions="$(phpenv completions "$command")"
    COMPREPLY=( $(compgen -W "$completions" -- "$word") )
  fi
}

complete -F _phpenv phpenv
