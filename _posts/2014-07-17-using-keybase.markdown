---
layout: post
title: "Using Keybase"
date: 2014-07-18 03:21:09 +0900
categories:
    - Technology
description: I just created my Keybase. You can see my PGP public key on https://keybase.io/yous and get the key via https://keybase.io/yous/key.asc.
keywords: keybase
redirect_from:
    - /p/20140718/
    - /2014/07/18/using-keybase/
    - /p/20140717/
twitter_card:
    image: http://yous.be/images/2014/07/17/logo.png
facebook:
    image: http://yous.be/images/2014/07/17/logo.png
---

## Keybase
{: #keybase}


![Keybase](/images/2014/07/17/logo.png "Keybase")

> Keybase will be a public directory of publicly auditable public keys. All paired, for convenience, with unique usernames.

I just created my [Keybase][]. You can see my PGP public key on [keybase.io/yous][] and get the key via `https://keybase.io/yous/key.asc`. Anyone can encrypt messages using my public key and then I could decrypt it using my private key and see the message with safety. All of these can be done in browser, in [Keybase][].

[Keybase]: https://keybase.io
[keybase.io/yous]: https://keybase.io/yous

## Keybase Proof
{: #keybase-proof}

Keybase provides several ways to prove own identity of a Twitter account, a GitHub account, websites and a bitcoin address. Still it can be done on the browser, also you can use [command line](https://keybase.io/docs/command_line) for it. I proved [my GitHub](https://github.com/yous) by [keybase.md](https://gist.github.com/yous/149b0775d2ff02eac323) and [this site]({{ site.url }}) by [keybase.txt](http://yous.be/keybase.txt). Also you can check it with command line like:

``` sh
$ keybase id yous
✔ public key fingerprint: 1BF1 AFE8 682E 45A2 11FF 2C0E 891B 7A9E 1D5A 400A
✔ "yous" on github: https://gist.github.com/149b0775d2ff02eac323
✔ admin of yous.be via HTTP: http://yous.be/keybase.txt
```

<!-- more -->

## Directory Signing
{: #directory-signing}

Command line program of Keybase provides `dir` command to sign or verify directory. First you should install command line, see the [installation docs](https://keybase.io/download). If you already have an account, just run `keybase login`. You can also signup with `keybase signup` in terminal.

At first, you should change directory to sign:

``` sh
~ $ cd Dropbox/Public
~/Dropbox/Public $ keybase dir sign
info: Success! Wrote SIGNED.md from 224 found items
```

then `~/Dropbox/Public/SIGNED.md` is generated. On same directory, veryfing directory is also possible with:

``` sh
~/Dropbox/Public $ keybase dir verify
info: Valid signature from keybase user yous
✔ public key fingerprint: 1BF1 AFE8 682E 45A2 11FF 2C0E 891B 7A9E 1D5A 400A
✔ "yous" on github: https://gist.github.com/149b0775d2ff02eac323
✔ admin of yous.be via HTTP: http://yous.be/keybase.txt
info: Signed 4 minutes ago (Fri Jul 18 2014 20:06:31 GMT+0900 (KST))
info: Success! 1 signature(s) verified; 224 items checked
```

## Using Custom Email
{: #using-custom-email}

When you create public key on [Keybase][], default UID has name as `keybase.io/<username>` and email as `<username>@keybase.io`. You can add UID with your real name and regular email. From [One GnuPG/PGP key pair, two emails?](http://superuser.com/questions/293184/one-gnupg-pgp-key-pair-two-emails):

``` sh
$ gpg --edit-key <username>@keybase.io
gpg> adduid
Real name: <name>
Email address: <email>
Comment: <comment or Return to none>
Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? o
Enter passphrase: <passphrase>
gpg> uid <uid>
gpg> trust
Your decision? 5
Do you really want to set this key to ultimate trust? (y/N) y
gpg> save
```

## Signing Commits
{: #signing-commits}

All the crypto of Keybase is performed with GPG, you can sign your tags and your commits. To setup your signing key, you need to get your key id by:

``` sh
$ gpg --list-secret-keys | grep "^sec"
sec   4096R/1D5A400A 2014-07-16
```

The `1D5A400A` part is your key id. Then simply you can set your signing key by:

``` sh
$ git config --global user.signingkey 1D5A400A
```

Also

``` sh
$ git config --global commit.gpgsign true
```

makes Git to sign every commits:

``` sh
$ mkdir tmp && cd tmp
$ git init
$ echo foo > foo
$ git add foo
$ git commit -m "Test commit of foo"

You need a passphrase to unlock the secret key for
user: "John Doe <john.doe@example.com>"
2048-bit RSA key, ID E79FBC2D, created 2014-07-16 (main key ID 1D5A400A)

[master (root-commit) 6cdfc26] Test commit of foo
 1 file changed, 1 insertion(+)
 create mode 100644 foo
```

After adding signed commits, you can see the signature of commits by using `--show-signature` option:

``` sh
$ git log --show-signature
commit 6cdfc26eb2273fed14181fe4a09b6240323b8930
gpg: Signature made 금  7/18 21:29:24 2014 KST using RSA key ID E79FBC2D
gpg: Good signature from "John Doe <john.doe@example.com>"
gpg:                 aka "keybase.io/jdoe <jdoe@keybase.io>"
Author: John Doe <john.doe@example.com>
Date:   Fri Jul 18 21:29:14 2014 +0900

    Test commit of foo

 foo | 1 +
 1 file changed, 1 insertion(+)
```

For more information, see [A Git Horror Story: Repository Integrity With Signed Commits][] by Mike Gerwitz.

[A Git Horror Story: Repository Integrity With Signed Commits]: http://mikegerwitz.com/papers/git-horror-story

## Contact Me
{: #contact-me}

So, now feel free to contact me via [keybase.io/yous][] and other <a href="{{ root_url }}/about">contacts</a>. The source of this site is available on [GitHub](https://github.com/yous/yous.be), forks and pull requests are welcome!
