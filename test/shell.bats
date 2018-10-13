#!/usr/bin/env bats

load test_helper

@test "shell integration disabled" {
  run phpenv shell
  assert_failure "phpenv: shell integration not enabled. Run \`phpenv init' for instructions."
}

@test "shell integration enabled" {
  eval "$(phpenv init -)"
  run phpenv shell
  assert_success "phpenv: no shell-specific version configured"
}

@test "no shell version" {
  mkdir -p "${PHPENV_TEST_DIR}/myproject"
  cd "${PHPENV_TEST_DIR}/myproject"
  echo "1.2.3" > .php-version
  PHPENV_VERSION="" run phpenv-sh-shell
  assert_failure "phpenv: no shell-specific version configured"
}

@test "shell version" {
  PHPENV_SHELL=bash PHPENV_VERSION="1.2.3" run phpenv-sh-shell
  assert_success 'echo "$PHPENV_VERSION"'
}

@test "shell version (fish)" {
  PHPENV_SHELL=fish PHPENV_VERSION="1.2.3" run phpenv-sh-shell
  assert_success 'echo "$PHPENV_VERSION"'
}

@test "shell revert" {
  PHPENV_SHELL=bash run phpenv-sh-shell -
  assert_success
  assert_line 0 'if [ -n "${PHPENV_VERSION_OLD+x}" ]; then'
}

@test "shell revert (fish)" {
  PHPENV_SHELL=fish run phpenv-sh-shell -
  assert_success
  assert_line 0 'if set -q PHPENV_VERSION_OLD'
}

@test "shell unset" {
  PHPENV_SHELL=bash run phpenv-sh-shell --unset
  assert_success
  assert_output <<OUT
PHPENV_VERSION_OLD="\$PHPENV_VERSION"
unset PHPENV_VERSION
OUT
}

@test "shell unset (fish)" {
  PHPENV_SHELL=fish run phpenv-sh-shell --unset
  assert_success
  assert_output <<OUT
set -gu PHPENV_VERSION_OLD "\$PHPENV_VERSION"
set -e PHPENV_VERSION
OUT
}

@test "shell change invalid version" {
  run phpenv-sh-shell 1.2.3
  assert_failure
  assert_output <<SH
phpenv: version \`1.2.3' not installed
false
SH
}

@test "shell change version" {
  mkdir -p "${PHPENV_ROOT}/versions/1.2.3"
  PHPENV_SHELL=bash run phpenv-sh-shell 1.2.3
  assert_success
  assert_output <<OUT
PHPENV_VERSION_OLD="\$PHPENV_VERSION"
export PHPENV_VERSION="1.2.3"
OUT
}

@test "shell change version (fish)" {
  mkdir -p "${PHPENV_ROOT}/versions/1.2.3"
  PHPENV_SHELL=fish run phpenv-sh-shell 1.2.3
  assert_success
  assert_output <<OUT
set -gu PHPENV_VERSION_OLD "\$PHPENV_VERSION"
set -gx PHPENV_VERSION "1.2.3"
OUT
}
