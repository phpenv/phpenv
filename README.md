## phpenv - PHP multi-version installation and management for humans.

### Key features:

 * Based on the totally awesome [rbenv](https://github.com/sstephenson/rbenv) and
[ruby-build](https://github.com/sstephenson/ruby-build), the way you like it
 * Build php directly from the git repository source, saves you bandwidth
 * Build multiple versions of the same release, exactly what you need
 * Easily customizable configuration options, gives you freedom
 * Restart a failed installation from anywhere, saves you time
 * Include custom build extensions both static and shared, gives you options
 * Includes Apache apxs support and switching versions, as you wish
 * Installs pear and pyrus for each installation (where supportod), as you prefer
 * Developed by humans for humans, just like you

My name is phpenv. I was designed for humans, to help simplify the management
of multiple PHP custom build installations.

I was originally inspired by the outstanding work of both the
 projects which
you already know and love with a whole bunch of PHP scentric additions
to help you build your first release, simplify managing and working
with diffirent releases and keep you building new release after new
release like there's nothing to it.

You are a PHP developer, like we are, and you not only have to have the
latest and freshest interpreter to spin your scripts but you also care to
see what how they get treated when submitted to older inturpretations.
Ever wondered why you can't run a CI on your own development machine? Well
you just founh the answer doing when taken for a ride building PHP
on their dev machines. Easily customize your configuration options and even
build pecl extensions into PHP or manually afterwards. Configure and install
custom builds of the same PHP release version directly from the PHP source
code repository kept in your local `.phpenv` folder.

## How It Works

phpenv operates on the per-user directory `~/.phpenv`. Version names in
phpenv correspond to subdirectories of `~/.phpenv/versions`. For
example, you might have `~/.phpenv/versions/5.3.8` and
`~/.phpenv/versions/5.4.0`.

Each version is a working tree with its own binaries, like
`~/.phpenv/versions/5.4.0/bin/php` and
`~/.phpenv/versions/5.3.8/bin/pyrus`. phpenv makes _shim binaries_
for every such binary across all installed versions of PHP.

These shims are simple wrapper scripts that live in `~/.phpenv/shims`
and detect which PHP version you want to use. They insert the
directory for the selected version at the beginning of your `$PATH`
and then execute the corresponding binary.

Because of the simplicity of the shim approach, all you need to use
phpenv is `~/.phpenv/shims` in your `$PATH` which will do the version
switching automagically.

## Installation

### Basic GitHub Checkout

This will get you going with the latest version of phpenv and make it
easy to fork and contribute any changes back upstream.

1. Check out phpenv into `~/.phpenv`.

        $ cd
        $ git clone git://github.com/phpenv/phpenv.git .phpenv

2. Add `~/.phpenv/bin` to your `$PATH` for access to the `phpenv`
   command-line utility.

        $ echo 'export PATH="$HOME/.phpenv/bin:$PATH"' >> ~/.bash_profile

3. Add phpenv init to your shell to enable shims and autocompletion.

        $ echo 'eval "$(phpenv init -)"' >> ~/.bash_profile

4. Restart your shell so the path changes take effect. You can now
   begin using phpenv.

        $ exec $SHELL

5. Rebuild the shim binaries. You should do this any time you install
   a new PHP binary.

        $ phpenv rehash

### Upgrading

If you've installed phpenv using the instructions above, you can
upgrade your installation at any time using git.

To upgrade to the latest development version of phpenv, use `git pull`:

    $ cd ~/.phpenv
    $ git pull

### Apache Setup

phpenv support dynamic switching for Apache apxs libraries and `install`
will build and install a `libphp5.so` shared library for Apache under
the `versions` `libexec` folder.

By calling `phpenv global` to show or change the global PHP version
a link is created under `~/.phpenv/lib/libphp5.so` for the appropriate
release build. This link can be used for Apache's `LoadModule php5_module`
directive and requires Apache to restart when changed.

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

### phpenv install

It is advisable to install the [ccache](http://ccache.samba.org/) caching
preprocessor which will greatly reduce the time taken to rebuild failed
installations.

The phpenv installation script was originally based on the
[php-build](https://github.com/CHH/php-build) installation script written by
[Christoph Hochstrasser (CHH)](https://github.com/CHH) but has (almost entirely)
been rewritten with humans in mind. Some of the differences to the original
includes:
 * use of the [php-src](https://github.com/php/php-src) repo to compile your
individual PHP installs as opposed to downloading a tarball from php.net.
 * reads configuration options from source files located in `.phpenv/etc`
 * allows you to do multiple builds per release
 * includes building custom extensions located in the ".phpenv/php-ext`
folder, as per the configuration source files, both static or shared.
 * allows you to continue a failed installation from anywhere
 * and more...

You can list the available PHP releases by running:

    $ phpenv install --releases

To build one of the listed releases run:

    $ phpenv install php-5.3.20

This command will checkout a branch to build in and install that release to
its own subdirectory in ~/.phpenv/versions/

The installation script gets its configuration options from source files in the
`.phpenv/etc` folder and also includes instructions to build extensions or sets
appropriate environment variables where required. These configuration options
are usually specific to your development environment but several defaults for
Darwin and dependencies installed with [homebrew](http://mxcl.github.com/homebrew/)
have been included for your convenience.

The configuration files are using the following naming convention:
```
<php major release><-optional specific build>.<platform>.source
```

If no qualifying specific build was found we fall back to the default major release
version (without specific build).

To install multiple builds of the same release simply add a unique name for your
additional builds after the release identifier.

    $phpenv install php-5.3.20 debug

Will use the configuration options source file located at `.phpenv/etc/php-5.3.20-debug.Darwin.source`
if installing on a Mac OS X environment and installs the version to `.phpenv/versions/5.3.20-debug`.

The build is kept in tact at location `phpenv/php-src` to simplify fault
finding and alloving you to continue the installation process in the event
of a failed build.

To continue from a previoun ntep in the installation process use the `--continue`
option.

    $phpenv install php-5.3.20 -c 4

To start from the configuring stage of the installation process and rerun
`./configure` using the updated information from your cenfiguration options
source file.

When restarting an installation from scratch it may be useful to clean
previously build and generated files, use

    $phpenv install --clean

When installing a different release version it may be useful to do a deep clean
and purge all previously build and generated files including those from custom
extension located at `.php-env/php-ext` and purge the ccache (if used), use

    $phpenv install --deep-clean

Running `phpenv install` with no arguments will output its usage, for detailed
help documentation, use

    $phpenv install --help


### phpenv global

Sets the global version of PHP to be used in all shells by writing
the version name to the `~/.phpenv/version` file. This version can be
overridden by a per-project `.phpenv-version` file, or by setting the
`PHPENV_VERSION` environment variable.

    $ phpenv global 5.4.0

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

    $ phpenv local 5.3.8

When run without a version number, `phpenv local` reports the currently
configured local version. You can also unset the local version:

    $ phpenv local --unset

### phpenv shell

Sets a shell-specific PHP version by setting the `PHPENV_VERSION`
environment variable in your shell. This version overrides both
project-specific versions and the global version.

    $ phpenv shell 5.3.9

When run without a version number, `phpenv shell` reports the current
value of `PHPENV_VERSION`. You can also unset the shell version:

    $ phpenv shell --unset

Note that you'll need phpenv's shell integration enabled (step 3 of
the installation instructions) in order to use this command. If you
prefer not to use shell integration, you may simply set the
`PHPENV_VERSION` variable yourself:

    $ export PHPENV_VERSION=5.3.13

### phpenv versions

Lists all PHP versions known to phpenv, and shows an asterisk next to
the currently active version.

    $ phpenv versions
      5.2.8
      5.3.13
    * 5.4.0 (set by /YOUR-USERNAME/.phpenv/global)

### phpenv version

Displays the currently active PHP version, along with information on
how it was set.

    $ phpenv version
    5.4.0 (set by /YOUR-USERNAME/.phpenv/version)

### phpenv rehash

Installs shims for all PHP binaries known to phpenv (i.e.,
`~/.phpenv/versions/*/bin/*`). Run this command after you install a new
version of PHP.

    $ phpenv rehash

### phpenv which

Displays the full path to the binary that phpenv will execute when you
run the given command.

    $ phpenv which pyrus
    /YOUR-USERNAME/.phpenv/versions/5.4.0/bin/pyrus

## Development

The phpenv source code is [hosted on
GitHub](https://github.com/phpenv/phpenv). It's clean, modular,
and easy to understand (thanks to the rbenv project), even if you're not a
shell hacker.

This project is basically a clone (Read: "search and replace") of the rbenv
project. It's in need of love and support. If you're interested in improving it
please feel free to fork, submit pull requests and file bugs on the [issue
tracker](https://github.com/phpenv/phpenv/issues).

### License

(The MIT license)

Copyright (c) 2012 Dominic Giglio

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
