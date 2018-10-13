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
  run phpenv-version-name
  assert_success "system"
}

@test "system version is not checked for existance" {
  PHPENV_VERSION=system run phpenv-version-name
  assert_success "system"
}

@test "PHPENV_VERSION can be overridden by hook" {
  create_version "5.5.7"
  create_version "5.6.3"
  create_hook version-name test.bash <<<"PHPENV_VERSION=5.6.3"

  PHPENV_VERSION=5.5.7 run phpenv-version-name
  assert_success "5.6.3"
}

@test "carries original IFS within hooks" {
  create_hook version-name hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
SH

  export PHPENV_VERSION=system
  IFS=$' \t\n' run phpenv-version-name env
  assert_success
  assert_line "HELLO=:hello:ugly:world:again"
}

@test "PHPENV_VERSION has precedence over local" {
  create_version "5.5.7"
  create_version "5.6.3"

  cat > ".php-version" <<<"5.5.7"
  run phpenv-version-name
  assert_success "5.5.7"

  PHPENV_VERSION=5.6.3 run phpenv-version-name
  assert_success "5.6.3"
}

@test "local file has precedence over global" {
  create_version "5.5.7"
  create_version "5.6.3"

  cat > "${PHPENV_ROOT}/version" <<<"5.5.7"
  run phpenv-version-name
  assert_success "5.5.7"

  cat > ".php-version" <<<"5.6.3"
  run phpenv-version-name
  assert_success "5.6.3"
}

@test "missing version" {
  PHPENV_VERSION=5.2 run phpenv-version-name
  assert_failure "phpenv: version \`5.2' is not installed (set by PHPENV_VERSION environment variable)"
}

@test "version with prefix in name" {
  create_version "5.5.7"
  cat > ".php-version" <<<"php-5.5.7"
  run phpenv-version-name
  assert_success
  assert_output "5.5.7"
}
