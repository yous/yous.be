---
layout: post
title: "Tomorrow Theme in Octopress"
date: 2013-12-04 21:00:20 +0900
comments: false
categories: Octopress Tomorrow-Theme
---

## Tomorrow Theme

I usually use Tomorrow Night Eighties of [Tomorrow Theme][] in Vim, iTerm2, IntelliJ IDEA (Android Studio). You can take a look of Tomorrow Theme.

[Tomorrow Theme]: https://github.com/chriskempson/tomorrow-theme

![Tomorrow Night Look][]
![Tomorrow Look][]
![Tomorrow Night Eighties Look][]
![Tomorrow Night Blue Look][]
![Tomorrow Night Bright][]

[Tomorrow Night Look]: https://github.com/ChrisKempson/Tomorrow-Theme/raw/master/Images/Tomorrow-Night.png
[Tomorrow Look]: https://github.com/ChrisKempson/Tomorrow-Theme/raw/master/Images/Tomorrow-Night-Bright.png
[Tomorrow Night Eighties Look]: https://github.com/ChrisKempson/Tomorrow-Theme/raw/master/Images/Tomorrow-Night-Eighties.png
[Tomorrow Night Blue Look]: https://github.com/ChrisKempson/Tomorrow-Theme/raw/master/Images/Tomorrow-Night-Blue.png
[Tomorrow Night Bright]: https://github.com/ChrisKempson/Tomorrow-Theme/raw/master/Images/Tomorrow-Night-Bright.png

So I made scss files for Octopress that overrides colors of `.highlight` and `.gist` class elements. Usual code blocks and embedded gists are properly highlighted. You can [preview][Syntax Highlighting Test] and get the [code][yous.github.io/sass/custom/_tomorrow].

[Syntax Highlighting Test]: /2013/12/03/syntax-highlighting-test/
[yous.github.io/sass/custom/_tomorrow]: https://github.com/yous/yous.github.io/tree/source/sass/custom/_tomorrow

<!-- more -->

## Usage

1. Download `_tomorrow` codes in [GitHub][_tomorrow].
2. Add `_tomorrow` folder to `sass/custom` and just add `@import` line after the last of the `sass/custom/_style.scss`.

[_tomorrow]: https://github.com/yous/yous.github.io/tree/source/sass/custom/_tomorrow

{% codeblock sass/custom/_style.scss %}
// Tomorrow Night
@import "custom/_tomorrow/tomorrow-night";

// Tomorrow
@import "custom/_tomorrow/tomorrow";

// Tomorrow Night Eighties
@import "custom/_tomorrow/tomorrow-night-eighties";

// Tomorrow Night Blue
@import "custom/_tomorrow/tomorrow-night-blue";

// Tomorrow Night Bright
@import "custom/_tomorrow/tomorrow-night-bright";
{% endcodeblock %}

## Fixes

- With default `sass/partial/_syntax.scss`, embedded gist code looks [weird][]. To fix them, we should override some styles.

[weird]: http://devspade.com/blog/2013/08/06/fixing-gist-embeds-in-octopress/

{% gist 8474011 %}

- Default `sass/partial/_syntax.scss` adds `box-shadow` and `text-shadow` to line numbers, also `box-shadow` to code block and gist. I removed these attributes and it is just can be done by overriding style in `sass/custom/_styles.scss`.

{% codeblock sass/custom/_styles.scss %}
.highlight .line-numbers, html .gist .gist-file .gist-syntax .highlight .line_numbers {
  @include box-shadow(none);
  text-shadow: none;
}

figure.code, .gist-file {
  @include box-shadow(none);
}
{% endcodeblock %}

- **This issue was fixed by this [commit][].** This blog uses [Whitespace][] theme. I found some problems that it overrides colors of code block to dark blue and it hides line numbers. To fix these problems, remove lines in `sass/custom/_styles.scss`.

[commit]: https://github.com/lucaslew/whitespace/commit/b047f268c804808fb8e2d6a17cbfe8669b9da6b4
[Whitespace]: https://github.com/lucaslew/whitespace

{% gist 7795229 %}
