#!/usr/bin/env bats

load test_helper

@test "default" {
  run phpenv-global
  assert_success
  assert_output "system"
}

@test "read PHPENV_ROOT/version" {
  mkdir -p "$PHPENV_ROOT"
  echo "1.2.3" > "$PHPENV_ROOT/version"
  run phpenv-global
  assert_success
  assert_output "1.2.3"
}

@test "set PHPENV_ROOT/version" {
  mkdir -p "$PHPENV_ROOT/versions/1.2.3"
  run phpenv-global "1.2.3"
  assert_success
  run phpenv-global
  assert_success "1.2.3"
}

@test "fail setting invalid PHPENV_ROOT/version" {
  mkdir -p "$PHPENV_ROOT"
  run phpenv-global "1.2.3"
  assert_failure "phpenv: version \`1.2.3' not installed"
}
