---
layout: post
title: "Ghost in the Shellcode 2014: inview Write-up"
date: 2014-01-20 22:21:24 +0900
comments: false
categories:
    - CTF
    - Write-up
keywords: ghost in the shellcode, inview
---

## <a id="question-3-inview"></a>Question 3 - inview

> Points: 150
>
> The key is in view, what is it? [File][]

[File]: https://2014.ghostintheshellcode.com/inview-324b8fb59c14da0d5ca1fe2c31192d80cec8e155

If the above link doesn't work, please use this [link][].

[link]: /downloads/2014/01/20/inview-324b8fb59c14da0d5ca1fe2c31192d80cec8e155

Extract file with this code:

``` sh
mv inview-324b8fb59c14da0d5ca1fe2c31192d80cec8e155 inview-324b8fb59c14da0d5ca1fe2c31192d80cec8e155.xz
xz -d inview-324b8fb59c14da0d5ca1fe2c31192d80cec8e155.xz
```

Then we can see some trailing whitespace in `inview-324b8fb59c14da0d5ca1fe2c31192d80cec8e155`.

## <a id="how-to-highlight-trailing-whitespace-in-vim"></a>How to Highlight Trailing Whitespace in Vim

Add this code to your `.vimrc`:

``` vim .vimrc
highlight ExtraWhitespace ctermbg=red guibg=red
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace //
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
if version >= 702
  autocmd BufWinLeave * call clearmatches()
end
```

Then [Vim] highlights trailing whitespace to red color.

[Vim]: http://www.vim.org

## <a id="how-to-solve"></a>How to Solve

I felt something weird, so I converted the file to hex code. In Vim:

    :%!xxd

Looking at whitespace, I realized there are `09(Tab)`, `0A(New Line)`, `20(Space)` with no rule. Right after that I came up with [Whitespace][]. Also there is a [interpreter written in JavaScript][]. Almost done! Just copy and paste the file content to site and press 'Exec' button. If you want to execute it in local, you can use [whitespacers][].

[Whitespace]: http://compsoc.dur.ac.uk/whitespace/
[interpreter written in JavaScript]: http://ws2js.luilak.net/interpreter.html
[whitespacers]: https://github.com/hostilefork/whitespacers

Finally the key is:

    WhitespaceProgrammingIsHard
