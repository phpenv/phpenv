#!/usr/bin/env bats

load test_helper

@test "commands" {
  run phpenv-commands
  assert_success
  assert_line "init"
  assert_line "rehash"
  assert_line "shell"
  refute_line "sh-shell"
  assert_line "echo"
}

@test "commands --sh" {
  run phpenv-commands --sh
  assert_success
  refute_line "init"
  assert_line "shell"
}

@test "commands in path with spaces" {
  path="${PHPENV_TEST_DIR}/my commands"
  cmd="${path}/phpenv-sh-hello"
  mkdir -p "$path"
  touch "$cmd"
  chmod +x "$cmd"

  PATH="${path}:$PATH" run phpenv-commands --sh
  assert_success
  assert_line "hello"
}

@test "commands --no-sh" {
  run phpenv-commands --no-sh
  assert_success
  assert_line "init"
  refute_line "shell"
}
