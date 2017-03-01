---
layout: post
title: "Boston Key Party CTF 2017: vimjail write-up"
date: 2017-03-01 09:34:52 +0000
categories:
    - CTF
description: "Write-up of Boston Key Party CTF 2017: vimjail."
keywords: boston key party, boston key party 2017, vim, write-up
redirect_from: /p/20170301/
---

## vimjail (pwn 150)

> - `ssh ctfuser@ec2-54-200-176-5.us-west-2.compute.amazonaws.com`
> - password: `loginPWforVimJail`
>
> Can you read the flag?
>
> _UPDATES_
> - (13:38 UTC Saturday): The flag is not in `/tmp`.
> - (13:31 EST Saturday): new ip

## Looking around

Well, you would do `ls` first when you logged in, so do we. And there was
`~/flagReader`.

``` sh
ctfuser@ip-172-31-31-196:~$ ls -als /home/ctfuser/flagReader
12 ---S--x--- 1 topsecretuser secretuser 8768 Feb 25 08:42 /home/ctfuser/flagReader
```

If you try completion by pressing Tab key or try to move around using `cd`, it
fails with an error message from rbash. It's restricted bash, but you can simply
run `bash` to escape.

While moving around, we found nothing special without `/.flag`. Also there were
some `.s[a-z][a-z]` files under `/var/tmp/` and `/tmp/`, created by
`secretuser`. But there are not in fixed location when the problem server was
changed, so we thought there would be a way to run Vim under `secretuser`'s
permission.

``` sh
ctfuser@ip-172-31-31-196:~$ ls -als /.flag
4 -r-------- 1 topsecretuser topsecretuser 39 Feb 25 08:42 /.flag
```

We also tried to find setuid or setgid files, but there was only the previous
`flagReader`.

``` sh
ctfuser@ip-172-31-31-196:/tmp$ find / -perm -4000 -o -perm -2000 -type f 2>/dev/null
/bin/ping
/bin/ping6
/bin/fusermount
/bin/umount
/bin/su
/bin/mount
/bin/ntfs-3g
/sbin/unix_chkpwd
/sbin/pam_extrausers_chkpwd
/usr/lib/x86_64-linux-gnu/utempter/utempter
/usr/lib/x86_64-linux-gnu/lxc/lxc-user-nic
/usr/lib/openssh/ssh-keysign
/usr/lib/snapd/snap-confine
/usr/lib/eject/dmcrypt-get-device
/usr/lib/dbus-1.0/dbus-daemon-launch-helper
/usr/lib/policykit-1/polkit-agent-helper-1
/usr/bin/crontab
/usr/bin/newuidmap
/usr/bin/at
/usr/bin/chage
/usr/bin/sudo
/usr/bin/bsd-write
/usr/bin/pkexec
/usr/bin/chfn
/usr/bin/expiry
/usr/bin/newgrp
/usr/bin/screen
/usr/bin/chsh
/usr/bin/gpasswd
/usr/bin/newgidmap
/usr/bin/ssh-agent
/usr/bin/passwd
/usr/bin/mlocate
/home/ctfuser/flagReader
```

<!-- more -->

## Jump into Vim

Suddenly [@zzoru](http://zzoru.github.io) mentioned that we can run
`sudo -u secretuser /usr/bin/rvim`. Later, I learned that `sudo` has `-l`,
`--list` option:

``` man
-l, --list  If no command is specified, list the allowed (and
            forbidden) commands for the invoking user (or the user
            specified by the -U option) on the current host.  A longer
            list format is used if this option is specified multiple
            times and the security policy supports a verbose output
            format.
```

So now we're able to run Vim under `secretuser`'s permission!

## rvim

So, what's rvim? You can see the description of it by typing `:help rvim` in
Vim:

``` vim
rvim    vim -Z      Like "vim", but in restricted mode (see |-Z|)   *rvim*
```

Again, `:help -Z`:

``` vim
                                                *-Z* *restricted-mode* *E145*
-Z              Restricted mode.  All commands that make use of an external
                shell are disabled.  This includes suspending with CTRL-Z,
                ":sh", filtering, the system() function, backtick expansion,
                delete(), rename(), mkdir(), writefile(), libcall(),
                job_start(), etc.
                {not in Vi}
```

Yes, it's the Vim version of rbash. We can't run `:!/home/ctfuser/flagReader`,
or `:set shell=/home/ctfuser/flagReader | shell` in restricted mode. Well, this
is the main content of vimjail.

## Jailbreak

Seeing `:version`, we found that it has extra patch 8.0.0056, so
[CVE-2016-1248](https://www.cvedetails.com/cve/CVE-2016-1248/) exploiting
modeline would also not work. However, it's containing `+python3` support. So
first we tried to execute Python with something like `:python3 print(1)`. And
that worked!

We just executed `flagReader`:

``` vim
:python3 import os; os.system('/home/ctfuser/flagReader')
```

Then it prints the flag. So the flag is
`flag{rVim_is_no_silverbullet!!!111elf}`.
