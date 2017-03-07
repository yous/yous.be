---
layout: post
title: "Pushing git repository to multiple remotes"
date: 2017-03-07 12:26:59 +0000
categories:
    - Git
description: "How to push a git repository to the multiple remote URLs."
keywords: git, push, multiple remotes
redirect_from: /p/20170307/
---

I'm currently managing my dotfiles repository on both of
[GitHub](https://github.com/yous/dotfiles) and
[Bitbucket](https://bitbucket.org/yous/dotfiles). These two repositories are the
same, but I don't want to remove one of them. I mainly use GitHub for hosting
code now, but the first place I uploaded my dotfiles to was Bitbucket.

I want to keep the HEAD of two remote repositories be the same, so when I push
code to my dotfiles, the both of them must be updated at the same time.

## Default git config

First, clone or init the repository.

``` sh
git clone https://github.com/yous/dotfiles.git
```

Then, as you know, the origin will be set to
`https://github.com/yous/dotfiles.git`. This is the content of `.git/config`:

``` gitconfig
[core]
	# ...
[remote "origin"]
	url = https://github.com/yous/dotfiles.git
	fetch = +refs/heads/*:refs/remotes/origin/*
[branch "master"]
	# ...
```

Note that there is the `url` attribute under `remote "origin"`.

## git remote set-url

Now we're going to run `git remote set-url` twice so that the repository will
have two push remote URLs. Setting _push_ remote URL is slightly different from
plaing `git remote set-url <name> <newurl>`. See `man git-remote`:

``` man
set-url
    Changes URLs for the remote. Sets first URL for remote <name> that
    matches regex <oldurl> (first URL if no <oldurl> is given) to
    <newurl>. If <oldurl> doesn't match any URL, an error occurs and
    nothing is changed.

    With --push, push URLs are manipulated instead of fetch URLs.

    With --add, instead of changing existing URLs, new URL is added.
```

So we need to run `git remote set-url --push <name> <newurl>`. Moreover, we need
two push URL, so the second command should be
`git remote set-url --add --push <name> <newurl>`. It's okay to specify
`--add --push` to the first command, too.

``` sh
git remote set-url --add --push origin https://github.com/yous/dotfiles.git
git remote set-url --add --push origin https://bitbucket.org/yous/dotfiles.git
```

Now, the content of `.git/config` would be like this:

``` gitconfig
[core]
	# ...
[remote "origin"]
	url = https://github.com/yous/dotfiles.git
	fetch = +refs/heads/*:refs/remotes/origin/*
	pushurl = https://github.com/yous/dotfiles.git
	pushurl = https://bitbucket.org/yous/dotfiles.git
[branch "master"]
	# ...
```

All done! Note that there are two `pushurl`s under `remote "origin"`. Now
`git push` automatically pushes to the both push remote URLs.
