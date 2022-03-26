#!/usr/bin/env bats

load test_helper

export GIT_DIR="${PHPENV_TEST_DIR}/.git"

setup() {
  mkdir -p "$HOME"
  git config --global user.name  "Tester"
  git config --global user.email "tester@test.local"
  cd "$PHPENV_TEST_DIR"
}

git_commit() {
  git commit --quiet --allow-empty -m "empty"
}

@test "default version" {
  assert [ ! -e "$PHPENV_ROOT" ]
  run phpenv---version
  assert_success
  [[ $output == "phpenv v"?.?.?-rc.1 ]]
}

@test "doesn't read version from non-phpenv repo" {
  git init
  git remote add origin https://github.com/homebrew/homebrew.git
  git_commit
  git tag v1.0

  run phpenv---version
  assert_success
  [[ $output == "phpenv v"?.?.?-rc.1 ]]
}

@test "reads version from git repo" {
  git init
  git remote add origin https://github.com/phpenvdev/phpenv.git
  git_commit
  git tag v1.0.0
  git_commit
  git_commit

  run phpenv---version
  assert_success "phpenv v1.0.0-2-g$(git rev-parse --short HEAD)"
}

@test "prints default version if no tags in git repo" {
  git init
  git remote add origin https://github.com/phpenvdev/phpenv.git
  git_commit

  run phpenv---version
  [[ $output == "phpenv v"?.?.?-rc.1 ]]
}
