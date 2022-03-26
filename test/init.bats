#!/usr/bin/env bats

load test_helper

@test "creates shims and versions directories" {
  assert [ ! -d "${PHPENV_ROOT}/shims" ]
  assert [ ! -d "${PHPENV_ROOT}/versions" ]
  run phpenv-init -
  assert_success
  assert [ -d "${PHPENV_ROOT}/shims" ]
  assert [ -d "${PHPENV_ROOT}/versions" ]
}

@test "auto rehash" {
  run phpenv-init -
  assert_success
  assert_line "command phpenv rehash 2>/dev/null"
}

@test "setup shell completions" {
  root="$(cd $BATS_TEST_DIRNAME/.. && pwd)"
  run phpenv-init - bash
  assert_success
  assert_line "source '${root}/test/../libexec/../completions/phpenv.bash'"
}

@test "detect parent shell" {
  SHELL=/bin/false run phpenv-init -
  assert_success
  assert_line "export PHPENV_SHELL=bash"
}

@test "detect parent shell from script" {
  mkdir -p "$PHPENV_TEST_DIR"
  cd "$PHPENV_TEST_DIR"
  cat > myscript.sh <<OUT
#!/bin/sh
eval "\$(phpenv-init -)"
echo \$PHPENV_SHELL
OUT
  chmod +x myscript.sh
  run ./myscript.sh /bin/zsh
  assert_success "sh"
}

@test "setup shell completions (fish)" {
  root="$(cd $BATS_TEST_DIRNAME/.. && pwd)"
  run phpenv-init - fish
  assert_success
  assert_line "source '${root}/test/../libexec/../completions/phpenv.fish'"
}

@test "fish instructions" {
  run phpenv-init fish
  assert [ "$status" -eq 1 ]
  assert_line 'status --is-interactive; and source (phpenv init -|psub)'
}

@test "option to skip rehash" {
  run phpenv-init - --no-rehash
  assert_success
  refute_line "phpenv rehash 2>/dev/null"
}

@test "adds shims to PATH" {
  export PATH="${BATS_TEST_DIRNAME}/../libexec:/usr/bin:/bin:/usr/local/bin"
  run phpenv-init - bash
  assert_success
  assert_line 0 'export PATH="'${PHPENV_ROOT}'/shims:${PATH}"'
}

@test "adds shims to PATH (fish)" {
  export PATH="${BATS_TEST_DIRNAME}/../libexec:/usr/bin:/bin:/usr/local/bin"
  run phpenv-init - fish
  assert_success
  assert_line 0 "set -gx PATH '${PHPENV_ROOT}/shims' \$PATH"
}

@test "can add shims to PATH more than once" {
  export PATH="${PHPENV_ROOT}/shims:$PATH"
  run phpenv-init - bash
  assert_success
  assert_line 0 'export PATH="'${PHPENV_ROOT}'/shims:${PATH}"'
}

@test "can add shims to PATH more than once (fish)" {
  export PATH="${PHPENV_ROOT}/shims:$PATH"
  run phpenv-init - fish
  assert_success
  assert_line 0 "set -gx PATH '${PHPENV_ROOT}/shims' \$PATH"
}

@test "outputs sh-compatible syntax" {
  run phpenv-init - bash
  assert_success
  assert_line '  case "$command" in'

  run phpenv-init - zsh
  assert_success
  assert_line '  case "$command" in'
}

@test "outputs fish-specific syntax (fish)" {
  run phpenv-init - fish
  assert_success
  assert_line '  switch "$command"'
  refute_line '  case "$command" in'
}
