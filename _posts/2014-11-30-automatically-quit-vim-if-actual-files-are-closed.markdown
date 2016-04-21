---
layout: post
title: "Automatically Quit Vim if Actual Files are Closed"
date: 2014-11-30 18:02:45 +0900
comments: false
categories:
    - Vim
description: How to close Vim automatically when remaining windows aren't important.
keywords: vim, auto, quit, help, quickfix, nerdtree, taglist
redirect_from: /p/20141130/
twitter_card:
    image: http://yous.be/images/2014/11/30/vim.png
facebook:
    image: http://yous.be/images/2014/11/30/vim.png
---

![Vim](/images/2014/11/30/vim_800.png "Vim")

## Sidebar

Many Vim user use plugins which open sidebar like [NERDTree](https://github.com/scrooloose/nerdtree) or [Tag List](https://github.com/vim-scripts/taglist.vim). In my case, I always open NERDTree and Tag List on Vim startup. Their file and tag navigation features are extremely handy.

We use `:q` to quit, `:q!` or `ZQ` to quit without saving, `:wq`, `:x` or `ZZ` to save and quit. But these commands are applied to only one buffer. NERDTree or Tag List windows are not closed until we close them individually or quit all using `:qa`.

## Getting into the Problem

But as one of the Vim users, I close it within a few minutes or even a few seconds after I opened it. I want to keep quitting Vim easy. Using `:qa` everytime doesn't make sence. Actually, [NERDTree gives us a tip](https://github.com/scrooloose/nerdtree#faq) to close Vim if the only window left open is a NERDTree:

``` vim
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
```

If I close the last window when a NERDTree exists, Vim automatically closes. But what if we have Tag List window also? `winnr("$")` returns the current window count, so the above code triggers only when the window count is 1. So Vim will quit automatically only when NERDTree is the last window.

<!-- more -->

## Not Interesting Buffer

There are some types of window which isn't important while quitting Vim.

1. Help

   We can look up documentation of Vim itself or its plugins by `:help` or `:h` command. This is one of the most powerful features of Vim, but these windows aren't editable and we don't need them while quitting Vim.

2. QuickFix

   Some plugins like [Syntastic](https://github.com/scrooloose/syntastic) or [Vim RuboCop](https://github.com/ngmy/vim-rubocop) show errors on QuickFix window and Vim supports navigating them with `:cnext` and `:cprev`. There windows aren't needed also.

3. NERDTree and Tag List

   Here is where we started.

## Investigate the Buffer

Vim buffers have its type. Help and QuickFix buffers also have it so we're ready to go. See `'buftype'` documentation:

``` vim
						*'buftype'* *'bt'* *E382*
'buftype' 'bt'		string (default: "")
			local to buffer
			{not in Vi}
			{not available when compiled without the |+quickfix|
			feature}
	The value of this option specifies the type of a buffer:
	  <empty>	normal buffer
	  nofile	buffer which is not related to a file and will not be
			written
	  nowrite	buffer which will not be written
	  acwrite	buffer which will always be written with BufWriteCmd
			autocommands. {not available when compiled without the
			|+autocmd| feature}
	  quickfix	quickfix buffer, contains list of errors |:cwindow|
			or list of locations |:lwindow|
	  help		help buffer (you are not supposed to set this
			manually)
```

Because `quickfix` and `help` type is already exists, all we have to do is retrieve that value. This code returns the buftype of current buffer:

``` vim
getbufvar(winbufnr(0), '&buftype')
```

Note that `winbufnr(0)` returns the number of the buffer in the current window.

For NERDTree and Tag List, we check the name of the buffer.

``` vim
bufname(winbufnr(0))
```

NERDTree has `t:NERDTreeBufName` for this, Tag List has same name for every buffer; `__Tag_List__`.

So we can check whether the current buffer is NERDTree or not with this:

``` vim
exists('t:NERDTreeBufName') && bufname(winbufnr(0)) == t:NERDTreeBufName
```

For Tag List:

``` vim
bufname(winbufnr(0)) == '__Tag_List__'
```

## Automatically Quit Vim

We can check the current buffer is important or not. Then how can we check that for every buffer? Now do some basic programming.

``` vim
function! CheckLeftBuffers()
  if tabpagenr('$') == 1
    let i = 1
    while i <= winnr('$')
      if getbufvar(winbufnr(i), '&buftype') == 'help' ||
          \ getbufvar(winbufnr(i), '&buftype') == 'quickfix' ||
          \ exists('t:NERDTreeBufName') &&
          \   bufname(winbufnr(i)) == t:NERDTreeBufName ||
          \ bufname(winbufnr(i)) == '__Tag_List__'
        let i += 1
      else
        break
      endif
    endwhile
    if i == winnr('$') + 1
      qall
    endif
    unlet i
  endif
endfunction
autocmd BufEnter * call CheckLeftBuffers()
```

Note that `CheckLeftBuffers()` will check buffers only when the tab page count is 1. It iterates every window and check its `'buftype'` is `'help'` or `'quickfix'`. If every window is Help window or QuickFix window, `i` becomes `winnr('$') + 1`. Then we're safe to quit all windows by calling `qall`. Finally we add `CheckLeftBuffers()` to `BufEnter *`, so it'll be called on everytime we close a window---**on the fly!**

You can see my actual [vimrc commit](https://github.com/yous/dotfiles/commit/735976604471bb6186d3867a30c421c839ad3ad4) and also check out my [dotfiles repo](https://github.com/yous/dotfiles)!

- **Update**: In gVim, executing `qall` won't work. You can use this line instead of `qall`:

  ``` vim
  call feedkeys(":qall\<CR>", 'n')
  ```

- **Update**: If you have multiple tabs open, `qall` will close all buffers left.
You may want to close only the current tab with `:q`, then you can use the
`only` command:

  ``` vim
  call feedkeys(":only\<CR>:q\<CR>", 'n')
  ```

This will work with other Vim distributions. If it doesn't or if you have another problems, feel free to [make an issue](https://github.com/yous/dotfiles/issues/new) or [contact me]({{ "/about/" | prepend: site.baseurl }}).
