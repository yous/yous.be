---
layout: post
title: "Integrate Homebrew Ruby with chruby"
date: 2019-01-15 16:34:26 +0000
categories:
  - Ruby
description: "No more compiling time with ruby-install!"
keywords: ruby, chruby, ruby-install, homebrew
redirect_from: /p/20190115/
twitter_card:
  image: https://yous.be/images/2019/01/15/compiling.png
facebook:
  image: https://yous.be/images/2019/01/15/compiling.png
---

For a while after [switching from RVM to chruby]({% post_url 2016-01-01-switching-rvm-to-chruby %}),
I've been quite satisfied with [chruby](https://github.com/postmodern/chruby),
except for one thing. Every time Ruby releases a new version, I had to compile
that version from scratch using [ruby-install](https://github.com/postmodern/ruby-install).
It takes quite a long time, and I should do that on every macOS device I use.

[![Compiling](/images/2019/01/15/compiling.png "'Are you stealing those LCDs?' 'Yeah, but I'm doing it while my code compiles.'")](http://xkcd.com/303/)

## Why should I compile?

I wanted to install pre-compiled Ruby. It should exist! Then I thought up
Homebrew. Almost every formula of Homebrew has "bottles" for multiple versions
of macOS. So I thought: 'Just use Homebrew Ruby with chruby!'

## Cleaning up

Homebrew Ruby is [keg-only](https://github.com/Homebrew/homebrew-core/commit/b4bf45228a60a9a64a0f17d0374b27ffe84c862c)
since 2.5.3, so if you had installed Homebrew Ruby earlier than or equal to
2.5.3, make sure to unlink it. Binaries of gems were placed under
`/usr/local/bin/`, so they can make problems related to PATH.

``` sh
brew unlink ruby
```

## Integrating Homebrew Ruby with ruby-install

By default, ruby-install installs Rubies into `~/.rubies`. If you install Ruby
2.6.0 using `ruby-install ruby 2.6.0`, then the Ruby goes to
`~/.rubies/ruby-2.6.0`. So what if we make a symbolic link under `~/.rubies`
pointing Homebrew Ruby?

``` sh
ln -s "$(brew --prefix)/Cellar/ruby/2.6.0" ~/.rubies/ruby-2.6.0
```

Specify `ruby-2.6.0` in `~/.ruby-version`, and opening a new shell works like a
charm!

``` sh
$ chruby
 * ruby-2.6.0
```

## Default gems

Although chruby sets `$GEM_HOME` and `$GEM_PATH` properly, Homebrew
intentionally removes binaries of bundled gems on installation, so you have to
install them using `gem install`.

``` sh
gem install bundler
gem install irb
```

## Updating Ruby

Not only when a new Ruby is released, but also Homebrew sometimes updates Ruby
for a new revision. The symlink is based on the cellar, so the link should be
updated.

``` sh
ln -sfn "$(brew --prefix)/Cellar/ruby/2.6.0_1" ~/.rubies/ruby-2.6.0
```

No more compiling time!
