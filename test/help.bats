#!/usr/bin/env bats

load test_helper

@test "without args shows summary of common commands" {
  run phpenv-help
  assert_success
  assert_line "Usage: phpenv <command> [<args>]"
  assert_line "Some useful phpenv commands are:"
}

@test "invalid command" {
  run phpenv-help hello
  assert_failure "phpenv: no such command \`hello'"
}

@test "shows help for a specific command" {
  mkdir -p "${PHPENV_TEST_DIR}/bin"
  cat > "${PHPENV_TEST_DIR}/bin/phpenv-hello" <<SH
#!shebang
# Usage: phpenv hello <world>
# Summary: Says "hello" to you, from phpenv
# This command is useful for saying hello.
echo hello
SH

  run phpenv-help hello
  assert_success
  assert_output <<SH
Usage: phpenv hello <world>

This command is useful for saying hello.
SH
}

@test "replaces missing extended help with summary text" {
  mkdir -p "${PHPENV_TEST_DIR}/bin"
  cat > "${PHPENV_TEST_DIR}/bin/phpenv-hello" <<SH
#!shebang
# Usage: phpenv hello <world>
# Summary: Says "hello" to you, from phpenv
echo hello
SH

  run phpenv-help hello
  assert_success
  assert_output <<SH
Usage: phpenv hello <world>

Says "hello" to you, from phpenv
SH
}

@test "extracts only usage" {
  mkdir -p "${PHPENV_TEST_DIR}/bin"
  cat > "${PHPENV_TEST_DIR}/bin/phpenv-hello" <<SH
#!shebang
# Usage: phpenv hello <world>
# Summary: Says "hello" to you, from phpenv
# This extended help won't be shown.
echo hello
SH

  run phpenv-help --usage hello
  assert_success "Usage: phpenv hello <world>"
}

@test "multiline usage section" {
  mkdir -p "${PHPENV_TEST_DIR}/bin"
  cat > "${PHPENV_TEST_DIR}/bin/phpenv-hello" <<SH
#!shebang
# Usage: phpenv hello <world>
#        phpenv hi [everybody]
#        phpenv hola --translate
# Summary: Says "hello" to you, from phpenv
# Help text.
echo hello
SH

  run phpenv-help hello
  assert_success
  assert_output <<SH
Usage: phpenv hello <world>
       phpenv hi [everybody]
       phpenv hola --translate

Help text.
SH
}

@test "multiline extended help section" {
  mkdir -p "${PHPENV_TEST_DIR}/bin"
  cat > "${PHPENV_TEST_DIR}/bin/phpenv-hello" <<SH
#!shebang
# Usage: phpenv hello <world>
# Summary: Says "hello" to you, from phpenv
# This is extended help text.
# It can contain multiple lines.
#
# And paragraphs.

echo hello
SH

  run phpenv-help hello
  assert_success
  assert_output <<SH
Usage: phpenv hello <world>

This is extended help text.
It can contain multiple lines.

And paragraphs.
SH
}
