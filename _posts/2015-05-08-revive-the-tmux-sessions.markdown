---
layout: post
title: "Revive the Tmux Sessions"
date: 2015-05-08 09:36:46 +0900
categories:
    - Technology
description: Revive the Tmux sessions when it seems dead.
keywords: tmux, attach, no session
redirect_from: /p/20150508/
---

On the previous day, I accidently removed `/tmp/tmux-1000/` directory. At first,
there seems no problem with Tmux. But when I created another SSH connection, I
saw this error message:

``` sh
$ tmux attach
no sessions
$ tmux list-sessions
failed to connect to server
```

But the Tmux prosesses were still there:

``` sh
$ ps -ef | grep tmux
59277 16305  0 May06 pts/0    00:00:00 tmux attach
```

Then I immediately noticed that the removing `/tmp/tmux-1000/` things made the
problem. And thankfully Tmux provides workaround. From the `tmux` manpage:

> -L socket-name
>
> tmux stores the server socket in a directory under /tmp (or
> TMPDIR if set); the default socket is named default.  This
> option allows a different socket name to be specified, allowing
> several independent tmux servers to be run.  Unlike -S a full
> path is not necessary: the sockets are all created in the same
> directory.
>
> If the socket is accidentally removed, the SIGUSR1 signal may
> be sent to the tmux server process to recreate it.

Now we can revive our Tmux sessions by sending a signal to recreate sockets:

``` sh
killall -s SIGUSR1 tmux
```

More simply, since the number of `SIGUSR1` is 10:

``` sh
killall -10 tmux
```

Then we can do `tmux attach` successfully. Yay!
