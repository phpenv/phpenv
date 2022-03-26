#!/usr/bin/env bats

load test_helper

create_executable() {
  local bin="${PHPENV_ROOT}/versions/${1}/${2}"
  mkdir -p "$bin"
  touch "${bin}/$3"
  chmod +x "${bin}/$3"
}

@test "empty rehash" {
  assert [ ! -d "${PHPENV_ROOT}/shims" ]
  run phpenv-rehash
  assert_success ""
  assert [ -d "${PHPENV_ROOT}/shims" ]
  rmdir "${PHPENV_ROOT}/shims"
}

@test "non-writable shims directory" {
  mkdir -p "${PHPENV_ROOT}/shims"
  chmod -w "${PHPENV_ROOT}/shims"
  run phpenv-rehash
  assert_failure "phpenv: cannot rehash: ${PHPENV_ROOT}/shims isn't writable"
}

@test "rehash in progress" {
  mkdir -p "${PHPENV_ROOT}/shims"
  touch "${PHPENV_ROOT}/shims/.phpenv-shim"
  run phpenv-rehash
  assert_failure "phpenv: cannot rehash: ${PHPENV_ROOT}/shims/.phpenv-shim exists"
}

@test "creates shims" {
  create_executable "5.6.0" "bin" "php"
  create_executable "5.6.0" "bin" "php-cgi"
  create_executable "5.6.0" "sbin" "php-fpm"
  create_executable "7.0.0" "bin" "php"
  create_executable "7.0.0" "bin" "php-cgi"
  create_executable "7.0.0" "sbin" "php-fpm"

  assert [ ! -e "${PHPENV_ROOT}/shims/php" ]
  assert [ ! -e "${PHPENV_ROOT}/shims/php-cgi" ]
  assert [ ! -e "${PHPENV_ROOT}/shims/php-fpm" ]

  run phpenv-rehash
  assert_success ""

  run ls "${PHPENV_ROOT}/shims"
  assert_success
  assert_output <<OUT
php
php-cgi
php-fpm
OUT
}

@test "removes outdated shims" {
  mkdir -p "${PHPENV_ROOT}/shims"
  touch "${PHPENV_ROOT}/shims/oldshim1"
  chmod +x "${PHPENV_ROOT}/shims/oldshim1"

  create_executable "7.0.0" "bin" "php"
  create_executable "7.0.0" "bin" "php-cgi"
  create_executable "7.0.0" "sbin" "php-fpm"

  run phpenv-rehash
  assert_success ""

  assert [ ! -e "${PHPENV_ROOT}/shims/oldshim1" ]
}

@test "do exact matches when removing stale shims" {
  create_executable "7.0.0" "bin" "phar"
  create_executable "7.0.0" "bin" "phar.phar"

  phpenv-rehash

  cp "$PHPENV_ROOT"/shims/{phar.phar,pear}
  cp "$PHPENV_ROOT"/shims/{phar.phar,phing}
  cp "$PHPENV_ROOT"/shims/{phar.phar,phpunit}
  chmod +x "$PHPENV_ROOT"/shims/{pear,phing,phpunit}

  run phpenv-rehash
  assert_success ""

  assert [ ! -e "${PHPENV_ROOT}/shims/pear" ]
  assert [ ! -e "${PHPENV_ROOT}/shims/phing" ]
  assert [ ! -e "${PHPENV_ROOT}/shims/phpunit" ]
}

@test "binary install locations containing spaces" {
  create_executable "dirname1 RC1" "bin" "php"
  create_executable "dirname2 snapshoot" "bin" "php-cgi"
  create_executable "dirname3 dev" "sbin" "php-fpm"

  assert [ ! -e "${PHPENV_ROOT}/shims/php" ]
  assert [ ! -e "${PHPENV_ROOT}/shims/php-cgi" ]
  assert [ ! -e "${PHPENV_ROOT}/shims/php-fpm" ]

  run phpenv-rehash
  assert_success ""

  run ls "${PHPENV_ROOT}/shims"
  assert_success
  assert_output <<OUT
php
php-cgi
php-fpm
OUT
}

@test "carries original IFS within hooks" {
  create_hook rehash hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
exit
SH

  IFS=$' \t\n' run phpenv-rehash
  assert_success
  assert_output "HELLO=:hello:ugly:world:again"
}

@test "sh-rehash in bash" {
  create_executable "7.0.0" "bin" "php"
  create_executable "7.0.0" "sbin" "php-fpm"
  PHPENV_SHELL=bash run phpenv-sh-rehash
  assert_success "hash -r 2>/dev/null || true"
  assert [ -x "${PHPENV_ROOT}/shims/php" ]
  assert [ -x "${PHPENV_ROOT}/shims/php-fpm" ]
}

@test "sh-rehash in fish" {
  create_executable "7.0.0" "bin" "php"
  create_executable "7.0.0" "sbin" "php-fpm"
  PHPENV_SHELL=fish run phpenv-sh-rehash
  assert_success ""
  assert [ -x "${PHPENV_ROOT}/shims/php" ]
  assert [ -x "${PHPENV_ROOT}/shims/php-fpm" ]
}
