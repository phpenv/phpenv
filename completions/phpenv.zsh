if [[ ! -o interactive ]]; then
    return
fi

compctl -K _phpenv phpenv

_phpenv() {
  local word words completions
  read -cA words
  word="${words[2]}"

  if [ "${#words}" -eq 2 ]; then
    completions="$(phpenv commands)"
  else
    completions="$(phpenv completions "${word}")"
  fi

  reply=("${(ps:\n:)completions}")
}
