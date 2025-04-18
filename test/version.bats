#!/usr/bin/env bats

load test_helper

create_version() {
  mkdir -p "${PHPENV_ROOT}/versions/$1"
}

setup() {
  mkdir -p "$PHPENV_TEST_DIR"
  cd "$PHPENV_TEST_DIR"
}

@test "no version selected" {
  assert [ ! -d "${PHPENV_ROOT}/versions" ]
  run phpenv-version
  assert_success "system"
}

@test "set by PHPENV_VERSION" {
  create_version "8.1.16"
  PHPENV_VERSION=8.1.16 run phpenv-version
  assert_success "8.1.16 (set by PHPENV_VERSION environment variable)"
}

@test "set by local file" {
  create_version "8.1.16"
  cat > ".php-version" <<<"8.1.16"
  run phpenv-version
  assert_success "8.1.16 (set by ${PWD}/.php-version)"
}

@test "set by global file" {
  create_version "8.1.16"
  cat > "${PHPENV_ROOT}/version" <<<"8.1.16"
  run phpenv-version
  assert_success "8.1.16 (set by ${PHPENV_ROOT}/version)"
}

@test "prefer local over global file" {
  create_version "8.1.16"
  create_version "8.4.0"
  cat > ".php-version" <<<"8.1.16"
  cat > "${PHPENV_ROOT}/version" <<<"8.4.0"
  run phpenv-version
  assert_success "8.1.16 (set by ${PWD}/.php-version)"
}
