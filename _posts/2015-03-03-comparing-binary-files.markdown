---
layout: post
title: "Comparing binary files"
date: 2015-03-03 19:13:29 +0900
categories:
    - Technology
description: How to check whether two binary files are the same or not.
keywords: compare, binary, fc, cmp, diff
redirect_from: /p/20150303/
---

## Seeing differences between files

As using [Git](http://git-scm.com/), looking changes of files with `git diff` is common. Always we can check the status of files with `git status`, including whether there is a new file that isn't added to index, existence of changed files.

I downloaded the syllabus of each course I registered before the start of the semester. This is the first week of semester, professors introduce their course with the _adjusted_ syllabus. Of course I can access the updated ones, but I can't sure that the files which already I have are the same with which I downloaded right before. I want to keep the old one and the new one both, avoid just overwriting them.

## Comparing binary files

I just wanted to check whether two binary files are the same or not, no matter what the difference is.

### Windows

You can use [`fc`](http://www.computerhope.com/fchlp.htm), file compare, which is Microsoft DOS command.

``` bat
fc /b file1 file2
```

The `/b` flag is for a binary comparison. If two files are the same, it prints a message like 'FC: no differences encountered', if they're not, it shows each byte of two files per line.

### Unix

You can use [`cmp`](http://en.wikipedia.org/wiki/Cmp_(Unix)) which compares two files byte by byte.

``` sh
cmp file1 file2
```

When two files are the same, it prints no message and return 0. If they are different, it prints some message and return 1.
