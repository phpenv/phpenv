## phpenv - PHP multi-version installation and management for humans.

### Key features:

My name is phpenv. I was designed for humans, to help simplify the management
of multiple PHP custom build installations.

I was originally inspired by the outstanding work of
[rbenv][rbenv-url] and [ruby-build][ruby-build-url]
with a whole bunch of PHP centric additions
to help you build your first release, simplify managing and working
with diffirent releases and keep you building new release after new
release like there's nothing to it.

You are a PHP developer, like we are, and you not only have to have the
latest and freshest interpreter to spin your scripts but you also care to
see what how they get treated when submitted to older interpretations.
Ever wondered why you can't run a PHP app on your own development machine? Well
you just found the answer doing when taken for a ride building PHP
on their dev machines. Easily customize your configuration options and even
build pecl extensions into PHP or manually afterwards. Configure and install
custom builds of the same PHP release version directly from the PHP source
code repository kept in your local `.phpenv` folder.

## How It Works

After phpenv injects itself into your PATH at installation time, any invocation
of `php`, `php-fpm`, or other PHP-related executable will first activate phpenv.
Then, phpenv scans the current project directory for a file named `.php-version`.
If found, that file determines the version of PHP that should be used within that
directory. phpenv then looks up that PHP version among those installed under
`~/.phpenv/versions/`.

phpenv expects each version to be a directory resulting from a PHP installation.
This means each directory has its own binaries, libraries, config files, man pages.
For example, each version has its own `php`, `php-fpm`, `pecl`, `pyrus`, `php.ini`.
phpenv detects which version to run for your project then calls the appropriate file.

You can choose the PHP version for your project with, for example:

```sh
cd Projects/my-php-project
# choose PHP 8.3.13
phpenv local 8.3.13
```

Doing so will update the `.php-version` file in the current directory with the
version that you've chosen. A different project of yours that is another directory
might be using a different version of PHP altogether - phpenv will seamlessly
transition from one PHP version to another when you cd into the project directory.

Finally, almost every aspect of phpenv's mechanism is customizable via plugins
written in bash.

## Installation

### Basic GitHub Checkout
For a more automated install, you can use [phpenv-installer][phpenv-installer-url].
If you prefer a manual approach, follow the steps below.

This will get you going with the latest version of phpenv and make it
easy to fork and contribute any changes back upstream.

1. Check out phpenv into `~/.phpenv`.

   ```sh
   git clone https://github.com/phpenv/phpenv.git ~/.phpenv
   ```

2. Add `~/.phpenv/bin` to your `$PATH` for access to the `phpenv`
   command-line utility.
   
   The `$PATH` variable is typically set in your shell initialization file.
   Common examples:
   - if you are using bash, check if `~/.bash_profile` exists.
   - if you are using another shell, check your specific shell configuration.
   - if the above do not exist, shells will typically default to `~/.profile`

   Assuming that your shell initialization is in `~/.profile`, then

   ```sh
   echo 'export PATH="$HOME/.phpenv/bin:$PATH"' >> ~/.profile
   ```

3. Add phpenv init to your shell to enable shims and autocompletion.

   ```sh
   echo 'eval "$(phpenv init -)"' >> ~/.profile
   ```

4. Restart your shell so the path changes take effect. You can now
   begin using phpenv.

   ```sh
   exec $SHELL -l
   ```

5. (Optional) Install php-build into it and any php. (See [php-build][php-build-url] home)

   ```sh
   git clone https://github.com/php-build/php-build $(phpenv root)/plugins/php-build
   phpenv install <php-version>
   ```

6. (Optional) Rebuild the shim binaries. You should do this any time you install
   a new PHP binary.

   ```sh
   phpenv rehash
   ```

### Upgrading

If you've installed phpenv using the instructions above, you can
upgrade your installation at any time using git.

To upgrade to the latest development version of phpenv, use `git pull`:

```sh
cd ~/.phpenv && git pull
```

### php-build configuration
By default, php-build will compile PHP with a default set of options specified by:
 - php-build [default configure options][php-build-default-configure-opts-url]
 - per-version configure options in the PHP build definition. For example, in [7.4.13](https://github.com/php-build/php-build/blob/master/share/php-build/definitions/7.4.13)
 - configure options specified in environment variables. See [the man page](https://github.com/php-build/php-build/blob/master/man/php-build.1.ronn) for details.

Typically, if you need to specify how PHP is built on your system, you can add configure options in the `PHP_BUILD_CONFIGURE_OPTS` variable, and add PHP extensions in the `PHP_BUILD_INSTALL_EXTENSION` variable.

### Webserver Setup
#### PHP-FPM
The preferred way of connecting phpenv applications is by using php-fpm after building php. Your webserver can then be configured to connect to the php-fpm instance. In this approach, php will run as the permissions of the invoking user, which is not necessarily as the web server.

php-fpm can be started in one of the following ways:
 - using an init script: by running `~/.phpenv/versions/$VERSION/etc/init.d/php-fpm`
 - using systemd: by installing `~/.phpenv/versions/$VERSION/etc/systemd/system/php-fpm.service`
 - using an init script: by writing your own custom init script
 - using systemd: by writing your own custom systemd unit
 - manually: by running `php-fpm (8)` and supplying command-line arguments

By default, php-fpm comes with a configuration file under `~/.phpenv/versions/$VERSION/etc/php-fpm.conf`, which it will look for when run. This configures php-fpm to listen on `localhost:9000` when started. You may edit or replace this file, or supply a different configuration file using the `--fpm-config` (`-y`) command line argument.

Instructions for connecting different webservers to php-fpm:
 - for Apache, see the [apache wiki article][apache-wiki-phpfpm]
 - for NGINX, see the [nginx wiki article][nginx-wiki-phpfpm]

#### Apache SAPI
Alternatively, you may still use the Apache php module by configuring [php-build][php-build-url] to build the libphp.so apache extension (directions to follow). libphp.so can then be found by apache under the `~/.phpenv/versions/$VERSION/libexec` folder. This file can be used for Apache's `LoadModule php5_module` directive and requires Apache to restart when changed.

### Neckbeard Configuration

Skip this section unless you must know what every line in your shell
profile is doing.

`phpenv init` is the only command that crosses the line of loading
extra commands into your shell. Here's what `phpenv init` actually does:

1. Sets up your shims path. This is the only requirement for phpenv to
   function properly. You could also do this by hand by prepending
   `~/.phpenv/shims` to your `$PATH`.

2. Installs autocompletion. This is entirely optional but pretty
   useful. Sourcing `~/.phpenv/completions/phpenv.bash` will set that
   up. There is also a `~/.phpenv/completions/phpenv.zsh` for Zsh
   users.

3. Rehashes shims. From time to time you'll need to rebuild your
   shim files. Doing this on init makes sure everything is up to
   date. You can always run `phpenv rehash` manually.

4. Installs the sh dispatcher. This bit is also optional, but allows
   phpenv and plugins to change variables in your current shell, making
   commands like `phpenv shell` possible. The sh dispatcher doesn't do
   anything crazy like override `cd` or hack your shell prompt, but if
   for some reason you need `phpenv` to be a real script rather than a
   shell function, you can safely skip it.

Run `phpenv init -` for yourself to see exactly what happens under the
hood.

## Usage

Like `git`, the `phpenv` command delegates to subcommands based on its
first argument. The most common subcommands are:

### phpenv help

Show the usage and useful help.  When you are in trouble, do this ;)

```sh
phpenv help
phpenv help <subcommand>
```

### phpenv install

[php-build][php-build-url] is a phpenv-compatible plugin that builds and installs php. To be able to use phpenv install, download and install the php-build plugin as described in step 5. of the install instructions above.

Before running phpenv install, make sure the development versions needed to build php are installed in your system. In particular, if you want to build the apache extension, make sure that apache2-dev (or your OS's equivalent) is installed.

### phpenv global

Sets the global version of PHP to be used in all shells by writing
the version name to the `~/.phpenv/version` file. This version can be
overridden by a per-project `.phpenv-version` file, or by setting the
`PHPENV_VERSION` environment variable.

```sh
phpenv global 5.4.0
```

The special version name `system` tells phpenv to use the system PHP
(detected by searching your `$PATH`).

When run without a version number, `phpenv global` reports the
currently configured global version.

### phpenv local

Sets a local per-project PHP version by writing the version name to
a `.phpenv-version` file in the current directory. This version
overrides the global, and can be overridden itself by setting the
`PHPENV_VERSION` environment variable or with the `phpenv shell`
command.

```sh
phpenv local 5.3.8
```

When run without a version number, `phpenv local` reports the currently
configured local version. You can also unset the local version:

```sh
phpenv local --unset
```

### phpenv shell

Sets a shell-specific PHP version by setting the `PHPENV_VERSION`
environment variable in your shell. This version overrides both
project-specific versions and the global version.

```sh
phpenv shell 5.3.9
```

When run without a version number, `phpenv shell` reports the current
value of `PHPENV_VERSION`. You can also unset the shell version:

```sh
phpenv shell --unset
```

Note that you'll need phpenv's shell integration enabled (step 3 of
the installation instructions) in order to use this command. If you
prefer not to use shell integration, you may simply set the
`PHPENV_VERSION` variable yourself:

```sh
export PHPENV_VERSION=5.3.13
```

### phpenv versions

Lists all PHP versions known to phpenv, and shows an asterisk next to
the currently active version.

```sh
$ phpenv versions
  5.2.8
  5.3.13
* 5.4.0 (set by /YOUR-USERNAME/.phpenv/global)
```

### phpenv version

Displays the currently active PHP version, along with information on
how it was set.

```sh
$ phpenv version
5.4.0 (set by /YOUR-USERNAME/.phpenv/version)
```

### phpenv rehash

Installs shims for all PHP binaries known to phpenv (i.e.,
`~/.phpenv/versions/*/bin/*`). Run this command after you install a new
version of PHP.

```sh
phpenv rehash
```

### phpenv which

Displays the full path to the binary that phpenv will execute when you
run the given command.

```sh
$ phpenv which pyrus
/YOUR-USERNAME/.phpenv/versions/5.4.0/bin/pyrus
```

## Environment variables

You can affect how phpenv operates with the following settings:

name | default | description
-----|---------|------------
`PHPENV_VERSION`| | Specifies the PHP version to be used.<br>Also see [`phpenv shell`](#phpenv-shell)
`PHPENV_ROOT` | `~/.phpenv` | Defines the directory under which PHP versions and shims reside.<br>Also see [`phpenv root`](#phpenv-root)
`PHPENV_DEBUG` | | Outputs debug information.<br>Also as `phpenv --debug <subcommand>`
`PHPENV_HOOK_PATH` | | Colon-separated list of paths searched for phpenv hooks.
`PHPENV_DIR` | `$PWD` | Directory to start searching for `.php-version` files.

### Uninstalling phpenv

The simplicity of phpenv makes it easy to temporarily disable it, or uninstall from the system.

1. To **disable** phpenv managing your PHP versions, simply comment or remove the `phpenv init` line from your shell startup configuration. This will remove phpenv shims directory from PATH, and future invocations like `php` will execute the system PHP version, bypassing phpenv completely.

   While disabled, `phpenv` will still be accessible on the command line, but your PHP projects won't be affected by version switching.

2. To completely **uninstall** phpenv, perform step (1) and then remove the phpenv root directory. This will **delete all PHP versions** that were installd under `` `phpenv root`/versions/ `.

## Development

The phpenv source code is [hosted on GitHub][phpenv-url]. It's clean, modular,
and easy to understand (thanks to the rbenv project), even if you're not a
shell hacker.

Tests are executed using [Bats][bats-url]

```sh
bats test
bats test/<file>.bats
```

This project is basically a clone (Read: "search and replace") of the rbenv
project. It's in need of love and support. If you're interested in improving it
please feel free to fork, submit [pull requests][phpenv-prs] and file bugs on the [issue
tracker][phpenv-issues].


### License

(The MIT license)

Copyright (c) 2012 Dominic Giglio\
Copyright (c) 2013 Nick Lombard\
Copyright (c) 2015 madumlao

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[original-url]: https://github.com/phpenv/phpenv
[php-build-url]: https://github.com/php-build/php-build
[php-build-default-configure-opts-url]: https://github.com/php-build/php-build/blob/master/share/php-build/default_configure_options
[phpenv-url]: https://github.com/phpenv/phpenv
[phpenv-issues]: https://github.com/phpenv/phpenv/issues
[phpenv-installer-url]: https://github.com/phpenv/phpenv-installer
[phpenv-prs]: https://github.com/phpenv/phpenv/pulls
[rbenv-url]: https://github.com/rbenv/rbenv
[ruby-build-url]: https://github.com/rbenv/ruby-build
[apache-wiki-phpfpm]: https://wiki.apache.org/httpd/PHP-FPM
[nginx-wiki-phpfpm]: https://www.nginx.com/resources/wiki/start/topics/examples/phpfcgi/
[bats-url]: https://github.com/bats-core/bats-core
