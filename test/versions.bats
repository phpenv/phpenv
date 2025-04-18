#!/usr/bin/env bats

load test_helper

create_version() {
  mkdir -p "${PHPENV_ROOT}/versions/$1"
}

setup() {
  mkdir -p "$PHPENV_TEST_DIR"
  cd "$PHPENV_TEST_DIR"
}

stub_system_php() {
  local stub="${PHPENV_TEST_DIR}/bin/php"
  mkdir -p "$(dirname "$stub")"
  touch "$stub" && chmod +x "$stub"
}

@test "no versions installed" {
  stub_system_php
  assert [ ! -d "${PHPENV_ROOT}/versions" ]
  run phpenv-versions
  assert_success "* system"
}

@test "not even system php available" {
  PATH="$(path_without php)" run phpenv-versions
  assert_failure
  assert_output "Warning: no PHP detected on the system"
}

@test "bare output no versions installed" {
  assert [ ! -d "${PHPENV_ROOT}/versions" ]
  run phpenv-versions --bare
  assert_success ""
}

@test "single version installed" {
  stub_system_php
  create_version "8.4"
  run phpenv-versions
  assert_success
  assert_output <<OUT
* system
  8.4
OUT
}

@test "single version bare" {
  create_version "8.4"
  run phpenv-versions --bare
  assert_success "8.4"
}

@test "multiple versions" {
  stub_system_php
  create_version "7.4.33"
  create_version "8.1.16"
  create_version "8.2.10"
  create_version "8.2.11"
  create_version "8.2snapshot"
  run phpenv-versions
  assert_success
  assert_output <<OUT
* system
  7.4.33
  8.1.16
  8.2snapshot
  8.2.10
  8.2.11
OUT
}

@test "indicates current version" {
  stub_system_php
  create_version "8.1.16"
  create_version "8.2.10"
  PHPENV_VERSION=8.1.16 run phpenv-versions
  assert_success
  assert_output <<OUT
  system
* 8.1.16 (set by PHPENV_VERSION environment variable)
  8.2.10
OUT
}

@test "bare doesn't indicate current version" {
  create_version "8.1.16"
  create_version "8.2.10"
  PHPENV_VERSION=8.1.16 run phpenv-versions --bare
  assert_success
  assert_output <<OUT
8.1.16
8.2.10
OUT
}

@test "globally selected version" {
  stub_system_php
  create_version "8.1.16"
  create_version "8.2.10"
  cat > "${PHPENV_ROOT}/version" <<<"8.1.16"
  run phpenv-versions
  assert_success
  assert_output <<OUT
  system
* 8.1.16 (set by ${PHPENV_ROOT}/version)
  8.2.10
OUT
}

@test "per-project version" {
  stub_system_php
  create_version "8.1.16"
  create_version "8.2.10"
  cat > ".php-version" <<<"8.1.16"
  run phpenv-versions
  assert_success
  assert_output <<OUT
  system
* 8.1.16 (set by ${PHPENV_TEST_DIR}/.php-version)
  8.2.10
OUT
}

@test "ignores non-directories under versions" {
  create_version "1.9"
  touch "${PHPENV_ROOT}/versions/hello"

  run phpenv-versions --bare
  assert_success "1.9"
}

@test "lists symlinks under versions" {
  create_version "7.4.33"
  ln -s "7.4.33" "${PHPENV_ROOT}/versions/7.4"

  run phpenv-versions --bare
  assert_success
  assert_output <<OUT
7.4
7.4.33
OUT
}

@test "doesn't list symlink aliases when --skip-aliases" {
  create_version "7.4.33"
  ln -s "7.4.33" "${PHPENV_ROOT}/versions/7.4"
  mkdir moo
  ln -s "${PWD}/moo" "${PHPENV_ROOT}/versions/8.1"

  run phpenv-versions --bare --skip-aliases
  assert_success

  assert_output <<OUT
7.4.33
8.1
OUT
}
