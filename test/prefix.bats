#!/usr/bin/env bats

load test_helper

@test "prefix" {
  mkdir -p "${PHPENV_TEST_DIR}/myproject"
  cd "${PHPENV_TEST_DIR}/myproject"
  echo "1.2.3" > .php-version
  mkdir -p "${PHPENV_ROOT}/versions/1.2.3"
  run phpenv-prefix
  assert_success "${PHPENV_ROOT}/versions/1.2.3"
}

@test "prefix for invalid version" {
  PHPENV_VERSION="1.2.3" run phpenv-prefix
  assert_failure "phpenv: version \`1.2.3' not installed"
}

@test "prefix for system" {
  mkdir -p "${PHPENV_TEST_DIR}/bin"
  touch "${PHPENV_TEST_DIR}/bin/php"
  chmod +x "${PHPENV_TEST_DIR}/bin/php"
  PHPENV_VERSION="system" run phpenv-prefix
  assert_success "$PHPENV_TEST_DIR"
}

@test "prefix for system in /" {
  mkdir -p "${BATS_TEST_DIRNAME}/libexec"
  cat >"${BATS_TEST_DIRNAME}/libexec/phpenv-which" <<OUT
#!/bin/sh
echo /bin/php
OUT
  chmod +x "${BATS_TEST_DIRNAME}/libexec/phpenv-which"
  PHPENV_VERSION="system" run phpenv-prefix
  assert_success "/"
  rm -f "${BATS_TEST_DIRNAME}/libexec/phpenv-which"
}

@test "prefix for invalid system" {
  PATH="$(path_without php)" run phpenv-prefix system
  assert_failure "phpenv: system version not found in PATH"
}
