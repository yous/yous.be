---
layout: post
title: "How to open binary plist files using vim-plist"
date: 2018-12-02 08:42:47 +0000
categories:
    - Vim
description: "How to open binary plist files when it's extension is not .plist."
keywords: vim, plist, binary, vim-plist
redirect_from: /p/20181202/
twitter_card:
    image: https://yous.be/images/2018/12/02/plist.png
facebook:
    image: https://yous.be/images/2018/12/02/plist.png
---

![Vim editing a binary plist file](/images/2018/12/02/plist.min.png)

Using macOS, you may have had experiences of handling plist files. For example,
`~/Library/Preferences/.GlobalPreferences.plist` file holds some configurations
of macOS. When you type `defaults write -g ApplePressAndHoldEnabled -bool false`
on terminal, the following lines are added to `.GlobalPreferences.plist`:

``` xml
<key>ApplePressAndHoldEnabled</key>
<false/>
```

So when you dig down the preferences or resources of macOS system, you'll meet
plist files.

## vim-plist

darfink's [vim-plist](https://github.com/darfink/vim-plist) plugin handles
\*.plist files quite well. A plist file is in one of three formats; json,
binary, xml. macOS is bundled with the `plutil` command that can convert a plist
file from one format to another. The plugin also uses `plutil` to handle read
and write of plist files.

The plugin registers autocmd for [`BufReadCmd` and `FileReadCmd`](https://github.com/darfink/vim-plist/blob/67280fb32b88ad75e255068dfe69b9f069421618/plugin/plist.vim#L19-L20)
to read \*.plist files, [`BufWriteCmd` and `FileWriteCmd`](https://github.com/darfink/vim-plist/blob/67280fb32b88ad75e255068dfe69b9f069421618/plugin/plist.vim#L16)
to write \*.plist files. `BufRead` and `BufWrite` events are triggered _after_
reading the file into the buffer, but `BufReadCmd` and `BufWriteCmd` events are
triggered _before_ reading the file, and that autocmd should handle actual read
and write operation of that file. These differences make handling plist files
more complex.

<!-- more -->

## Problems

### \*.strings files

Overall, the plugin is quite useful and seamless. But recently, I found some
\*.strings plist files under `/System/Library`, almost of them in binary
formats. The plugin registers autocmds only for \*.plist files, so there is no
chance to convert them to readable formats.

At first, I've considered to register an autocmd for \*.strings file, but I'm
not sure about that `.strings` extension is only used for plist file, and also
there can be other extensions with plist contents (for example, \*.nib files are
plist, too).

### Saving a new file

darfink's vim-plist checks `g:plist_save_format` and `b:plist_save_format`
before writing to plist files. The buffer-local variable is set when the plugin
reads the file and detect the format. The global one is set by user, and
overrides buffer-local one.

I don't want the plugin to override the content of plist files with different
format, so I haven't set `g:plist_save_format`. Then the problem raised. Open a
new plist file, like `vim test.plist`, and save it after editing. Then the
plugin didn't set `b:plist_save_format` because it's a new file, and I also
didn't set `g:plist_save_format`, so the plugin don't know the format to use for
saving.

I think this problem can be solved by patching the plugin, but its last commit
is pushed in 2014, which makes me use the faster way.

### Incomplete plist files (Update: 2019-06-18)

vim-plist always uses `plutil -convert` command when opening plist files. But
`plutil` checks whether the given file is valid or not. This leads to a problem
when we have incomplete plist files. Say a plist file is tracked by git, and
when there is a merge conflict, that plist file will contain SCM conflict
markers.

``` xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<<<<<<< HEAD
    <key>other_content</key>
    <integer>4</integer>
=======
    <key>content</key>
    <integer>5</integer>
>>>>>>> master
    <key>test</key>
    <integer>3</integer>
</dict>
</plist>
```

With vim-plist, we will never be able to edit this file because vim-plist will
refuse to load it into the buffer.

## Solving the problems with .vimrc

### Binary plist files

I decided to check if the file is binary plist file or not, and load with
functions of vim-plist plugin. The checking process is easy, because the file
starts with `bplist`. At first, I think it's okay to register an autocmd for
`BufReadCmd` because calling functions of the plugin should be easy. So my first
try was:

``` vim
function! s:DetectBinaryPlist()
  let l:filename = expand('<afile>')
  if filereadable(l:filename)
    let l:content = readfile(l:filename, 'b', 1)
    if len(content) > 0 && content[0] =~# '^bplist'
      return 1
    endif
  endif
  return 0
endfunction
autocmd BufReadCmd *
      \ if s:DetectBinaryPlist() |
      \   call plist#Read(1) |
      \   call plist#ReadPost() |
      \ endif
```

Can you see the problem? This makes Vim returns an empty buffer when it reads a
file that's not a binary plist file. As I said above, `BufReadCmd` should handle
actual read and write operation of the file. If it's not a binary plist file,
Vim won't read anything according to this code.

So I changed `BufReadCmd` to `BufRead`. This event happens _after_ reading the
file into the buffer, so I have to empty the buffer.

``` vim
function! s:ConvertBinaryPlist()
  silent! execute '%d'
  call plist#Read(1)
  call plist#ReadPost()
endfunction
autocmd BufRead *
      \ if getline(1) =~# '^bplist' |
      \   call s:ConvertBinaryPlist() |
      \ endif
```

The `getline(1)` reads the first line of the buffer, and we can call it because
it's after reading the file. It's working quite well, so at that time, I wanted
to bring the writing functionality also.

``` vim
function! s:ConvertBinaryPlist()
  silent! execute '%d'
  call plist#Read(1)
  call plist#ReadPost()

  autocmd! BufWriteCmd,FileWriteCmd <buffer>
  autocmd BufWriteCmd,FileWriteCmd <buffer>
        \ call plist#Write()
endfunction
```

Note that the `autocmd!` line means deleting every other `BufWriteCmd` and
`FileWriteCmd` autocmds for that buffer, and the second line registers
`BufWriteCmd` and `FileWriteCmd` for that buffer.

But when I saved after editing a \*.strings file, I saw this error message:

```
<stdin>: Property List error: Unable to convert string to correct encoding / JSON error: JSON text did not start with array or object and option to allow fragments not set.
```

After poking around, I found that the `fileencoding` is set to `latin1`. The
original file is binary and we just replaced the contents of the buffer, the
`fileencoding` was not properly set. So I just set it to UTF-8.

``` vim
function! s:ConvertBinaryPlist()
  silent! execute '%d'
  call plist#Read(1)
  call plist#ReadPost()
  set fileencoding=utf-8

  autocmd! BufWriteCmd,FileWriteCmd <buffer>
  autocmd BufWriteCmd,FileWriteCmd <buffer>
        \ call plist#Write()
endfunction
```

### Saving a new file

It's simple:

``` vim
autocmd BufNewFile *.plist
      \ if !get(b:, 'plist_original_format') |
      \   let b:plist_original_format = 'xml' |
      \ endif
```

We don't write binary file by our own hands, so a new plist file would be in xml
format.

### Disable `autocmd`s of vim-plist (Update: 2019-06-18)

I decided to remove default `autocmd`s of vim-plist. The plist files I open
or edit are either in XML format or binary format. When the file is in binary
format, it's handled by above vimrc. When the file is in XML format, it doesn't
need to be converted as I'll save them in the same format.

``` vim
let g:loaded_plist = 1
let g:plist_display_format = 'xml'
let g:plist_save_format = ''
let g:plist_json_filetype = 'json'
```

When `g:loaded_plist` exists, vim-plist will do nothing. In
[plugin/plist.vim](https://github.com/darfink/vim-plist/blob/master/plugin/plist.vim),
it registers `autocmd`s and set default values to global variables. So here we
set global variables of vim-plist. The default value of `g:plist_json_filetype`
is `'javascript'`, but I set it to `'json'` as Vim can handle that filetype.

## Conclusion

So this is the complete part of my .vimrc for binary plist files:

``` vim
function! s:ConvertBinaryPlist()
  silent! execute '%d'
  call plist#Read(1)
  call plist#ReadPost()
  set fileencoding=utf-8

  augroup BinaryPlistWrite
    autocmd! BufWriteCmd,FileWriteCmd <buffer>
    autocmd BufWriteCmd,FileWriteCmd <buffer> call plist#Write()
  augroup END
endfunction
augroup BinaryPlistRead
  autocmd!
  autocmd BufRead *
        \ if getline(1) =~# '^bplist' |
        \   call s:ConvertBinaryPlist() |
        \ endif
  autocmd BufNewFile *.plist
        \ if !get(b:, 'plist_original_format') |
        \   let b:plist_original_format = 'xml' |
        \ endif
augroup END
" Disable default autocmds
let g:loaded_plist = 1
let g:plist_display_format = 'xml'
let g:plist_save_format = ''
let g:plist_json_filetype = 'json'
```

It's also available on [GitHub](https://github.com/yous/dotfiles/blob/0d95f7a13f70fe755ff9d1e35b64a42bcbf99973/vimrc#L1684-L1711),
you can visit my [dotfiles](https://github.com/yous/dotfiles) repository!
