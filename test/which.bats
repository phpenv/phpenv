#!/usr/bin/env bats

load test_helper

create_executable() {
  local bin
  if [[ $1 == */* ]]; then bin="$1"
  else bin="${PHPENV_ROOT}/versions/${1}/bin"
  fi
  mkdir -p "$bin"
  touch "${bin}/$2"
  chmod +x "${bin}/$2"
}

@test "outputs path to executable" {
  create_executable "5.5" "php"
  create_executable "7.0" "php-cgi"

  PHPENV_VERSION=5.5 run phpenv-which php
  assert_success "${PHPENV_ROOT}/versions/5.5/bin/php"

  PHPENV_VERSION=7.0 run phpenv-which php-cgi
  assert_success "${PHPENV_ROOT}/versions/7.0/bin/php-cgi"
}

@test "searches PATH for system version" {
  create_executable "${PHPENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${PHPENV_ROOT}/shims" "kill-all-humans"

  PHPENV_VERSION=system run phpenv-which kill-all-humans
  assert_success "${PHPENV_TEST_DIR}/bin/kill-all-humans"
}

@test "searches PATH for system version (shims prepended)" {
  create_executable "${PHPENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${PHPENV_ROOT}/shims" "kill-all-humans"

  PATH="${PHPENV_ROOT}/shims:$PATH" PHPENV_VERSION=system run phpenv-which kill-all-humans
  assert_success "${PHPENV_TEST_DIR}/bin/kill-all-humans"
}

@test "searches PATH for system version (shims appended)" {
  create_executable "${PHPENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${PHPENV_ROOT}/shims" "kill-all-humans"

  PATH="$PATH:${PHPENV_ROOT}/shims" PHPENV_VERSION=system run phpenv-which kill-all-humans
  assert_success "${PHPENV_TEST_DIR}/bin/kill-all-humans"
}

@test "searches PATH for system version (shims spread)" {
  create_executable "${PHPENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${PHPENV_ROOT}/shims" "kill-all-humans"

  PATH="${PHPENV_ROOT}/shims:${PHPENV_ROOT}/shims:/tmp/non-existent:$PATH:${PHPENV_ROOT}/shims" \
    PHPENV_VERSION=system run phpenv-which kill-all-humans
  assert_success "${PHPENV_TEST_DIR}/bin/kill-all-humans"
}

@test "doesn't include current directory in PATH search" {
  mkdir -p "$PHPENV_TEST_DIR"
  cd "$PHPENV_TEST_DIR"
  touch kill-all-humans
  chmod +x kill-all-humans
  PATH="$(path_without "kill-all-humans")" PHPENV_VERSION=system run phpenv-which kill-all-humans
  assert_failure "phpenv: kill-all-humans: command not found"
}

@test "version not installed" {
  create_executable "7.0" "php-cgi"
  PHPENV_VERSION=5.6 run phpenv-which php-cgi
  assert_failure "phpenv: version \`5.6' is not installed (set by PHPENV_VERSION environment variable)"
}

@test "no executable found" {
  create_executable "5.5" "php-cgi"
  PHPENV_VERSION=5.5 run phpenv-which pear
  assert_failure "phpenv: pear: command not found"
}

@test "no executable found for system version" {
  PATH="$(path_without "pear")" PHPENV_VERSION=system run phpenv-which pear
  assert_failure "phpenv: pear: command not found"
}

@test "executable found in other versions" {
  create_executable "5.5" "php"
  create_executable "5.6" "php-cgi"
  create_executable "7.0" "php-cgi"

  PHPENV_VERSION=5.5 run phpenv-which php-cgi
  assert_failure
  assert_output <<OUT
phpenv: php-cgi: command not found

The \`php-cgi' command exists in these PHP versions:
  5.6
  7.0
OUT
}

@test "carries original IFS within hooks" {
  create_hook which hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
exit
SH

  IFS=$' \t\n' PHPENV_VERSION=system run phpenv-which anything
  assert_success
  assert_output "HELLO=:hello:ugly:world:again"
}

@test "discovers version from phpenv-version-name" {
  mkdir -p "$PHPENV_ROOT"
  cat > "${PHPENV_ROOT}/version" <<<"5.5"
  create_executable "5.5" "php"

  mkdir -p "$PHPENV_TEST_DIR"
  cd "$PHPENV_TEST_DIR"

  PHPENV_VERSION= run phpenv-which php
  assert_success "${PHPENV_ROOT}/versions/5.5/bin/php"
}
