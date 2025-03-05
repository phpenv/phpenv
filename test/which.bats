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
  create_executable "7.4.33" "php"
  create_executable "8.1.16" "pecl"

  PHPENV_VERSION=7.4.33 run phpenv-which php
  assert_success "${PHPENV_ROOT}/versions/7.4.33/bin/php"

  PHPENV_VERSION=8.1.16 run phpenv-which pecl
  assert_success "${PHPENV_ROOT}/versions/8.1.16/bin/pecl"
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
  bats_require_minimum_version 1.5.0
  mkdir -p "$PHPENV_TEST_DIR"
  cd "$PHPENV_TEST_DIR"
  touch kill-all-humans
  chmod +x kill-all-humans
  PATH="$(path_without "kill-all-humans")" PHPENV_VERSION=system run -127 phpenv-which kill-all-humans
  assert_failure "phpenv: kill-all-humans: command not found"
}

@test "version not installed" {
  create_executable "8.1.16" "pecl"
  PHPENV_VERSION=8.0.16 run phpenv-which pecl
  assert_failure "phpenv: version \`8.0.16' is not installed (set by PHPENV_VERSION environment variable)"
}

@test "no executable found" {
  bats_require_minimum_version 1.5.0
  create_executable "8.1.16" "pecl"
  PHPENV_VERSION=8.1.16 run -127 phpenv-which pear
  assert_failure "phpenv: pear: command not found"
}

@test "no executable found for system version" {
  bats_require_minimum_version 1.5.0
  PATH="$(path_without "pear")" PHPENV_VERSION=system run -127 phpenv-which pear
  assert_failure "phpenv: pear: command not found"
}

@test "executable found in other versions" {
  bats_require_minimum_version 1.5.0
  create_executable "7.4.33" "php"
  create_executable "8.1.16" "pecl"
  create_executable "8.1.17" "pecl"

  PHPENV_VERSION=7.4.33 run -127 phpenv-which pecl
  assert_failure
  assert_output <<OUT
phpenv: pecl: command not found

The \`pecl' command exists in these PHP versions:
  8.1.16
  8.1.17
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
  cat > "${PHPENV_ROOT}/version" <<<"7.4.33"
  create_executable "7.4.33" "php"

  mkdir -p "$PHPENV_TEST_DIR"
  cd "$PHPENV_TEST_DIR"

  PHPENV_VERSION='' run phpenv-which php
  assert_success "${PHPENV_ROOT}/versions/7.4.33/bin/php"
}
