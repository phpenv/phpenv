#!/usr/bin/env bats

load test_helper

create_executable() {
  name="${1?}"
  shift 1
  bin="${PHPENV_ROOT}/versions/${PHPENV_VERSION}/bin"
  mkdir -p "$bin"
  { if [ $# -eq 0 ]; then cat -
    else echo "$@"
    fi
  } | sed -Ee '1s/^ +//' > "${bin}/$name"
  chmod +x "${bin}/$name"
}

@test "fails with invalid version" {
  export PHPENV_VERSION="2.0"
  run phpenv-exec php -v
  assert_failure "phpenv: version \`2.0' is not installed (set by PHPENV_VERSION environment variable)"
}

@test "fails with invalid version set from file" {
  mkdir -p "$PHPENV_TEST_DIR"
  cd "$PHPENV_TEST_DIR"
  echo 1.9 > .php-version
  run phpenv-exec rspec
  assert_failure "phpenv: version \`1.9' is not installed (set by $PWD/.php-version)"
}

@test "completes with names of executables" {
  export PHPENV_VERSION="2.0"
  create_executable "php" "#!/bin/sh"
  create_executable "phar" "#!/bin/sh"

  phpenv-rehash
  run phpenv-completions exec
  assert_success
  assert_output <<OUT
--help
phar
php
OUT
}

@test "carries original IFS within hooks" {
  create_hook exec hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
SH

  export PHPENV_VERSION=system
  IFS=$' \t\n' run phpenv-exec env
  assert_success
  assert_line "HELLO=:hello:ugly:world:again"
}

@test "forwards all arguments" {
  export PHPENV_VERSION="2.0"
  create_executable "php" <<SH
#!$BASH
echo \$0
for arg; do
  # hack to avoid bash builtin echo which can't output '-e'
  printf "  %s\\n" "\$arg"
done
SH

  run phpenv-exec php -w "/path to/php script.php" -- extra args
  assert_success
  assert_output <<OUT
${PHPENV_ROOT}/versions/2.0/bin/php
  -w
  /path to/php script.php
  --
  extra
  args
OUT
}

@test "supports php -S <cmd>" {
  export PHPENV_VERSION="2.0"

  # emulate `php -S' behavior
  create_executable "php" <<SH
#!$BASH
if [[ \$1 == "-S"* ]]; then
  found="\$(PATH="\${phpPATH:-\$PATH}" which \$2)"
  # assert that the found executable has php for shebang
  if head -n1 "\$found" | grep php >/dev/null; then
    \$BASH "\$found"
  else
    echo "php: no PHP script found in input (LoadError)" >&2
    exit 1
  fi
else
  echo 'php 2.0 (phpenv test)'
fi
SH

  create_executable "phar" <<SH
#!/usr/bin/env php
echo hello phar
SH

  phpenv-rehash
  run php -S phar
  assert_success "hello phar"
}
