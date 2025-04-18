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
  cat > my-version <<<"8.1.16"
  run phpenv-version-file-read my-version
  assert_success "8.1.16"
}

@test "ignores leading spaces" {
  cat > my-version <<<"  8.1.16"
  run phpenv-version-file-read my-version
  assert_success "8.1.16"
}

@test "reads only the first word from file" {
  cat > my-version <<<"8.1.16-p194@tag 7.4.33 hi"
  run phpenv-version-file-read my-version
  assert_success "8.1.16-p194@tag"
}

@test "loads only the first line in file" {
  cat > my-version <<IN
7.4.33 one
8.1.16 two
IN
  run phpenv-version-file-read my-version
  assert_success "7.4.33"
}

@test "ignores leading blank lines" {
  cat > my-version <<IN

8.1.16
IN
  run phpenv-version-file-read my-version
  assert_success "8.1.16"
}

@test "handles the file with no trailing newline" {
  echo -n "7.4.33" > my-version
  run phpenv-version-file-read my-version
  assert_success "7.4.33"
}

@test "ignores carriage returns" {
  cat > my-version <<< $'8.1.16\r'
  run phpenv-version-file-read my-version
  assert_success "8.1.16"
}

@test "prevents directory traversal" {
  cat > my-version <<<".."
  run phpenv-version-file-read my-version
  assert_failure "phpenv: invalid version in \`my-version'"

  cat > my-version <<<"../foo"
  run phpenv-version-file-read my-version
  assert_failure "phpenv: invalid version in \`my-version'"
}

@test "disallows path segments in version string" {
  cat > my-version <<<"foo/bar"
  run phpenv-version-file-read my-version
  assert_failure "phpenv: invalid version in \`my-version'"
}
