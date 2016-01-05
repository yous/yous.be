---
layout: post
title: "Switching RVM to chruby"
date: 2016-01-01 11:26:07 +0000
comments: false
categories:
    - Ruby
description: "I've found RVM's gemsets are no longer useful to me."
keywords: ruby, rvm, chruby
redirect_from: /p/20160101/
---

I've found RVM's gemsets are no longer useful to me. I used to make a separate
gemset for each project by placing `.ruby-version` and `.ruby-gemset` file in
each project directory. But whenever a Ruby release come out, I repeated
uninstalling previous version and then clean installing new version. So I
decided to move to [chruby](https://github.com/postmodern/chruby), smaller and
simpler one.

## Goodbye, RVM

``` sh
rvm implode
```

Also if you have additional script lines loading RVM, remove them. I left them
to make it work only if RVM is installed.

``` sh
[[ -s "$HOME/.rvm/scripts/rvm/" ]] && source "$HOME/.rvm/scripts/rvm"
```

## Installing ruby-install

[ruby-install](https://github.com/postmodern/ruby-install) handles installations
of various Rubies.

If you're on OS X:

``` sh
brew install ruby-install
```

If you're on Arch Linux:

``` sh
yaourt -S ruby-install
```

Otherwise:

``` sh
wget -O ruby-install-0.6.0.tar.gz
https://github.com/postmodern/ruby-install/archive/v0.6.0.tar.gz
tar -xzvf ruby-install-0.6.0.tar.gz
cd ruby-install-0.6.0/
sudo make install
```

## Installing chruby

If you're on OS X:

``` sh
brew install chruby
```

Otherwise:

``` sh
wget -O chruby-0.3.9.tar.gz
https://github.com/postmodern/chruby/archive/v0.3.9.tar.gz
tar -xzvf chruby-0.3.9.tar.gz
cd chruby-0.3.9/
sudo make install
```

Then all I need to do is to load it from startup script, `~/.*shrc`.

``` sh
if [ -e /usr/local/share/chruby/chruby.sh ]; then
  source /usr/local/share/chruby/chruby.sh
  source /usr/local/share/chruby/auto.sh
fi
```

The `auto.sh` is for auto-switching the current version of Ruby according to
`.ruby-version` file of the current directory. This is optional.

chruby provides ways to [migrate Rubies from another Ruby
manager](https://github.com/postmodern/chruby#migrating), but I started from
scratch, so installed latest Ruby using ruby-install.

``` sh
ruby-install ruby 2.3.0
```

Then `which ruby` will points to some path under `~/.rubies` directory.

``` sh
which ruby
~/.rubies/ruby-2.3.0/bin/ruby
```

Now it's possible to auto-switch the Ruby version with `.ruby-version` file or
manually with chruby commands like `chruby ruby-2.3.0` or `chruby system`, etc.
