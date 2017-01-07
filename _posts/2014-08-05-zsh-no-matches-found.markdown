---
layout: post
title: "zsh: no matches found"
date: 2014-08-05 14:31:03 +0900
categories:
    - Zsh
description: Zsh allows Filename Generation and Pattern Matching (Globbing) using square brackets and other characters. That may cause problem with shell commands.
keywords: zsh, no matches found, globbing, rake install, head^
redirect_from: /p/20140805/
external-url: http://marcboquet.com/blog/2011/07/24/zsh-no-matches-found/
---

With the use of [Git][] or [Octopress][] (typically [Rake][]), we type `[`, `]`, `^` characters to terminal:

[Git]: http://www.git-scm.com
[Octopress]: http://octopress.org
[Rake]: https://github.com/ruby/rake

``` sh
git reset HEAD^
```

``` sh
rake install[classic]
```

Some [Zsh][] users know what would happen when we type that commands:

[Zsh]: http://www.zsh.org

``` sh
zsh: no matches found: HEAD^
```

``` sh
zsh: no matches found: install[classic]
```

This is caused by Zsh:

> zsh allows Filename Generation and Pattern Matching (Globbing) using square brackets and other characters (explained in the [zsh guide](http://zsh.sourceforge.net/Guide/zshguide05.html), section 5.9).

The solution is simple:

> The solution, found in the [zsh FAQ](http://zsh.sourceforge.net/FAQ/zshfaq03.html) (section 3.4), is simply adding a line in ~/.zshrc that disables globbing for a single command:

``` sh
alias rake="noglob rake"
```

Aliasing `git` is also useful:

``` sh
alias git="noglob git"
```
