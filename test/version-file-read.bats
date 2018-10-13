#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "${PHPENV_TEST_DIR}/myproject"
  cd "${PHPENV_TEST_DIR}/myproject"
}

@test "fails without arguments" {
  run phpenv-version-file-read
  assert_failure ""
}

@test "fails for invalid file" {
  run phpenv-version-file-read "non-existent"
  assert_failure ""
}

@test "fails for blank file" {
  echo > my-version
  run phpenv-version-file-read my-version
  assert_failure ""
}

@test "reads simple version file" {
  cat > my-version <<<"5.6.3"
  run phpenv-version-file-read my-version
  assert_success "5.6.3"
}

@test "ignores leading spaces" {
  cat > my-version <<<"  5.6.3"
  run phpenv-version-file-read my-version
  assert_success "5.6.3"
}

@test "reads only the first word from file" {
  cat > my-version <<<"5.6.3RC1@tag 5.5.7 hi"
  run phpenv-version-file-read my-version
  assert_success "5.6.3RC1@tag"
}

@test "loads only the first line in file" {
  cat > my-version <<IN
5.5.7 one
5.6.3 two
IN
  run phpenv-version-file-read my-version
  assert_success "5.5.7"
}

@test "ignores leading blank lines" {
  cat > my-version <<IN

5.6.3
IN
  run phpenv-version-file-read my-version
  assert_success "5.6.3"
}

@test "handles the file with no trailing newline" {
  echo -n "5.5.7" > my-version
  run phpenv-version-file-read my-version
  assert_success "5.5.7"
}

@test "ignores carriage returns" {
  cat > my-version <<< $'5.6.3\r'
  run phpenv-version-file-read my-version
  assert_success "5.6.3"
}
