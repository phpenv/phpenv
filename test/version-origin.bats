#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$PHPENV_TEST_DIR"
  cd "$PHPENV_TEST_DIR"
}

@test "reports global file even if it doesn't exist" {
  assert [ ! -e "${PHPENV_ROOT}/version" ]
  run phpenv-version-origin
  assert_success "${PHPENV_ROOT}/version"
}

@test "detects global file" {
  mkdir -p "$PHPENV_ROOT"
  touch "${PHPENV_ROOT}/version"
  run phpenv-version-origin
  assert_success "${PHPENV_ROOT}/version"
}

@test "detects PHPENV_VERSION" {
  PHPENV_VERSION=1 run phpenv-version-origin
  assert_success "PHPENV_VERSION environment variable"
}

@test "detects local file" {
  echo "system" > .php-version
  run phpenv-version-origin
  assert_success "${PWD}/.php-version"
}

@test "reports from hook" {
  create_hook version-origin test.bash <<<"PHPENV_VERSION_ORIGIN=plugin"

  PHPENV_VERSION=1 run phpenv-version-origin
  assert_success "plugin"
}

@test "carries original IFS within hooks" {
  create_hook version-origin hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
SH

  export PHPENV_VERSION=system
  IFS=$' \t\n' run phpenv-version-origin env
  assert_success
  assert_line "HELLO=:hello:ugly:world:again"
}

@test "doesn't inherit PHPENV_VERSION_ORIGIN from environment" {
  PHPENV_VERSION_ORIGIN=ignored run phpenv-version-origin
  assert_success "${PHPENV_ROOT}/version"
}
