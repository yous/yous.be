---
layout: post
title: "Tomorrow Theme in Octopress"
date: 2013-12-04 21:00:20 +0900
comments: false
categories:
    - Octopress
    - Tomorrow Theme
keywords: octopress, tomorrow theme
redirect_from: /p/20131204/
facebook:
    image: https://github.com/ChrisKempson/Tomorrow-Theme/raw/master/Images/Tomorrow-Night.png
twitter_card:
    image: https://github.com/ChrisKempson/Tomorrow-Theme/raw/master/Images/Tomorrow-Night.png
---

## <a id="tomorrow-theme"></a>Tomorrow Theme

I usually use Tomorrow Night Eighties of [Tomorrow Theme][] in [Vim][], [iTerm2][], [IntelliJ IDEA][] ([Android Studio][]). You can take a look of Tomorrow Theme.

[Tomorrow Theme]: https://github.com/chriskempson/tomorrow-theme
[Vim]: http://www.vim.org
[iTerm2]: http://www.iterm2.com
[IntelliJ IDEA]: http://www.jetbrains.com/idea/
[Android Studio]: http://developer.android.com/sdk/installing/studio.html

{% img https://github.com/ChrisKempson/Tomorrow-Theme/raw/master/Images/Tomorrow-Night.png Tomorrow Night %}
{% img https://github.com/ChrisKempson/Tomorrow-Theme/raw/master/Images/Tomorrow.png Tomorrow %}
{% img https://github.com/ChrisKempson/Tomorrow-Theme/raw/master/Images/Tomorrow-Night-Eighties.png Tomorrow Night Eighties %}
{% img https://github.com/ChrisKempson/Tomorrow-Theme/raw/master/Images/Tomorrow-Night-Blue.png Tomorrow Night Blue %}
{% img https://github.com/ChrisKempson/Tomorrow-Theme/raw/master/Images/Tomorrow-Night-Bright.png Tomorrow Night Bright %}

So I made scss files for Octopress that overrides colors of `.highlight` and `.gist` class elements. Usual code blocks and embedded gists are properly highlighted. The [demo][Syntax Highlighting Test] and the [code][yous.github.io/sass/custom] are available.

[Syntax Highlighting Test]: /2013/12/03/syntax-highlighting-test/
[yous.github.io/sass/custom]: https://github.com/yous/yous.github.io/tree/source/sass/custom

<!-- more -->

## <a id="usage"></a>Usage

1. Download `tomorrow` folder and `_tomorrow.scss` from [GitHub][yous.github.io/sass/custom].
2. Put files to `sass/custom` and enable just one `@import` line of `_tomorrow.scss`. For example, if you want to use Tomorrow Night Eighties theme:

``` scss sass/custom/_tomorrow.scss
// @import "tomorrow/tomorrow-night";
// @import "tomorrow/tomorrow";
@import "tomorrow/tomorrow-night-eighties";
// @import "tomorrow/tomorrow-night-blue";
// @import "tomorrow/tomorrow-night-bright";
```

## <a id="fixes"></a>Fixes

- With default `sass/partial/_syntax.scss`, embedded gist code looks [weird][]. To fix them, we should override some styles.

[weird]: http://devspade.com/blog/2013/08/06/fixing-gist-embeds-in-octopress/

{% gist 8474011 %}

- Default `sass/partial/_syntax.scss` adds `box-shadow` and `text-shadow` to line numbers, also `box-shadow` to code block and gist. I removed these attributes and it is just can be done by overriding style in `sass/custom/_styles.scss`.

``` scss sass/custom/_styles.scss
.highlight .line-numbers, html .gist .gist-file .gist-syntax .highlight .line_numbers {
  @include box-shadow(none);
  text-shadow: none;
}

figure.code, .gist-file {
  @include box-shadow(none);
}
```

- **This issue was fixed by this [commit][].** This blog uses [Whitespace][] theme. I found some problems that it overrides colors of code block to dark blue and it hides line numbers. To fix these problems, remove lines in `sass/custom/_styles.scss`.

[commit]: https://github.com/lucaslew/whitespace/commit/b047f268c804808fb8e2d6a17cbfe8669b9da6b4
[Whitespace]: https://github.com/lucaslew/whitespace

{% gist 7795229 %}
