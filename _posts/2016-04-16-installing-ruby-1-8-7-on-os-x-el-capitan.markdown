---
layout: post
title: "Installing Ruby 1.8.7 on OS X El Capitan"
date: 2016-04-16 13:08:13 +0000
comments: false
categories:
    - Ruby
description: "Well… Why would you do that?"
keywords: ruby, 1.8.7, 1.8.7-p374, chruby, os x, el capitan, yosemite, mavericks
redirect_from: /p/20160416/
---

## A bug in Ruby 1.8.7

There is a bug in Ruby 1.8.7's exponentiation. See
["Exponentiation in Ruby 1.8.7 Returns Wrong Answers"](http://stackoverflow.com/questions/12009799/exponentiation-in-ruby-1-8-7-returns-wrong-answers).

``` irb
>> 2 ** 62
=> 4611686018427387904
>> 2 ** 63
=> -9223372036854775808
>> 2 ** 64
=> 0
```

Note that following gives the correct result:

``` irb
>> 2 ** 62 * 2
=> 9223372036854775808
```

## Supporting an ancient Ruby

Seeing this bug, I wanted to reproduce this by myself, so I just tried to
install Ruby 1.8.7 on OS X 10.11.4. As I'm using
[chruby](https://github.com/postmodern/chruby), I used
[ruby-install](https://github.com/postmodern/ruby-install).

``` sh
ruby-install ruby 1.8.7
```

But there are several errors:

``` sh
...
gcc -I. -I../.. -I../../. -I../.././ext/openssl -DRUBY_EXTCONF_H=\"extconf.h\" -I/usr/local/opt/openssl/include -I/usr/local/opt/readline/include -I/usr/local/opt/libyaml/include -I/usr/local/opt/gdbm/include  -D_XOPEN_SOURCE -D_DARWIN_C_SOURCE   -fno-common -g -O2 -pipe -fno-common   -c ossl.c
ossl.c:118:1: error: unknown type name 'STACK'; did you mean '_STACK'?
OSSL_IMPL_SK2ARY(x509, X509)
^
ossl.c:95:22: note: expanded from macro 'OSSL_IMPL_SK2ARY'
ossl_##name##_sk2ary(STACK *sk)                 \
                     ^
/usr/local/opt/openssl/include/openssl/stack.h:72:3: note: '_STACK' declared here
} _STACK;                       /* Use STACK_OF(...) instead */
  ^
...
4 errors generated.
make[1]: *** [ossl.o] Error 1
make: *** [all] Error 1
!!! Compiling ruby 1.8.7 failed!
```

This is because of the version of OpenSSL used for compilation is too high for
Ruby 1.8.7, see
[rbenv/ruby-build#445](https://github.com/rbenv/ruby-build/issues/445). After
some searching about OpenSSL and Ruby 1.8.7, I found that RVM is using
openssl098 for Ruby 1.8.7 compilation. But, unfortunately, they decided to
remove it from homebrew/versions tap because of deprecation and security issues.
See
[Homebrew/homebrew-versions#1150](https://github.com/Homebrew/homebrew-versions/issues/1150)
for the issue and
[the commit](https://github.com/Homebrew/homebrew-versions/commit/4e169f22cc48e61e2ed6e2f80a5414fe281db335)
removing openssl098.

## Building Ruby 1.8.7

As I just wanted to reproduce a bug, I used the `openssl098.rb` right before the
removal.

``` sh
brew install https://github.com/Homebrew/homebrew-versions/raw/586b7e9012a3ed1f9df6c43d0483c65549349289/openssl098.rb
```

Then we can provide `--with-openssl-dir` option to ruby-install.

``` sh
ruby-install ruby 1.8.7 -- --with-openssl-dir=/usr/local/opt/openssl098
```

It'll be successful! You can use Ruby 1.8.7 on OS X El Capitan.

``` sh
$ ruby --version
ruby 1.8.7 (2008-05-31 patchlevel 0) [i686-darwin15.4.0]
```

Finally I was able to reproduce the bug.

``` irb
>> 2 ** 62
=> 4611686018427387904
>> 2 ** 63
=> -9223372036854775808
>> 2 ** 64
=> 0
```

Also, for Ruby 1.8.7-p374, you don't need openssl098, but you may need X11. If
you don't need tk, then try the following command:

``` sh
ruby-install ruby 1.8.7-p374 -- --without-tk
```

This version of Ruby 1.8.7 still has the same bug.
