#!/usr/bin/env bats

load test_helper

create_executable() {
  local bin="${PHPENV_ROOT}/versions/${1}/${2}"
  mkdir -p "$bin"
  touch "${bin}/$3"
  chmod +x "${bin}/$3"
}

@test "finds versions where present" {
  create_executable "5.6.0" "bin" "php"
  create_executable "5.6.0" "bin" "php-cgi"
  create_executable "5.6.0" "sbin" "php-fpm"
  create_executable "7.0.0" "bin" "php"
  create_executable "7.0.0" "bin" "pear"

  run phpenv-whence php
  assert_success
  assert_output <<OUT
5.6.0
7.0.0
OUT

  run phpenv-whence php-cgi
  assert_success "5.6.0"

  run phpenv-whence php-fpm
  assert_success "5.6.0"

  run phpenv-whence pear
  assert_success "7.0.0"
}

@test "finds versions where present with path" {
  create_executable "5.6.0" "bin" "php"
  create_executable "5.6.0" "bin" "php-cgi"
  create_executable "5.6.0" "sbin" "php-fpm"
  create_executable "7.0.0" "bin" "php"
  create_executable "7.0.0" "bin" "pear"

  run phpenv-whence --path php
  assert_success
  assert_output <<OUT
${PHPENV_ROOT}/versions/5.6.0/bin/php
${PHPENV_ROOT}/versions/7.0.0/bin/php
OUT

  run phpenv-whence --path php-cgi
  assert_success "${PHPENV_ROOT}/versions/5.6.0/bin/php-cgi"

  run phpenv-whence --path php-fpm
  assert_success "${PHPENV_ROOT}/versions/5.6.0/sbin/php-fpm"

  run phpenv-whence --path pear
  assert_success "${PHPENV_ROOT}/versions/7.0.0/bin/pear"
}
