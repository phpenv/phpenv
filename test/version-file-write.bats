#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$PHPENV_TEST_DIR"
  cd "$PHPENV_TEST_DIR"
}

@test "invocation without 2 arguments prints usage" {
  run phpenv-version-file-write
  assert_failure "Usage: phpenv version-file-write <file> <version>"
  run phpenv-version-file-write "one" ""
  assert_failure
}

@test "setting nonexistent version fails" {
  assert [ ! -e ".php-version" ]
  run phpenv-version-file-write ".php-version" "7.4.33"
  assert_failure "phpenv: version \`7.4.33' not installed"
  assert [ ! -e ".php-version" ]
}

@test "writes value to arbitrary file" {
  mkdir -p "${PHPENV_ROOT}/versions/7.4.33"
  assert [ ! -e "my-version" ]
  run phpenv-version-file-write "${PWD}/my-version" "7.4.33"
  assert_success ""
  assert [ "$(cat my-version)" = "7.4.33" ]
}
