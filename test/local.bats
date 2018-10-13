#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "${PHPENV_TEST_DIR}/myproject"
  cd "${PHPENV_TEST_DIR}/myproject"
}

@test "no version" {
  assert [ ! -e "${PWD}/.php-version" ]
  run phpenv-local
  assert_failure "phpenv: no local version configured for this directory"
}

@test "local version" {
  echo "1.2.3" > .php-version
  run phpenv-local
  assert_success "1.2.3"
}

@test "discovers version file in parent directory" {
  echo "1.2.3" > .php-version
  mkdir -p "subdir" && cd "subdir"
  run phpenv-local
  assert_success "1.2.3"
}

@test "ignores PHPENV_DIR" {
  echo "1.2.3" > .php-version
  mkdir -p "$HOME"
  echo "7.0-home" > "${HOME}/.php-version"
  PHPENV_DIR="$HOME" run phpenv-local
  assert_success "1.2.3"
}

@test "sets local version" {
  mkdir -p "${PHPENV_ROOT}/versions/1.2.3"
  run phpenv-local 1.2.3
  assert_success ""
  assert [ "$(cat .php-version)" = "1.2.3" ]
}

@test "changes local version" {
  echo "5.0-pre" > .php-version
  mkdir -p "${PHPENV_ROOT}/versions/1.2.3"
  run phpenv-local
  assert_success "5.0-pre"
  run phpenv-local 1.2.3
  assert_success ""
  assert [ "$(cat .php-version)" = "1.2.3" ]
}

@test "unsets local version" {
  touch .php-version
  run phpenv-local --unset
  assert_success ""
  assert [ ! -e .php-version ]
}
