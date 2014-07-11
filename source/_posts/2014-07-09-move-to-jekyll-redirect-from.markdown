---
layout: post
title: "Move to 'jekyll-redirect-from'"
date: 2014-07-09 15:41:31 +0900
comments: false
categories:
    - Octopress
description: I had some problems with 'jekyll_alias_generator'. Now I moved to 'jekyll-redirect-from'.
keywords: redirect, alias, shortcut, octopress, jekyll, jekyll redirect from
redirect_from: /p/20140709/
---

## <a id="problems-with-jekyll-alias-generator"></a>Problems with jekyll_alias_generator

I wrote ["How to Add Redirects to Post URL on Octopress"]({% post_url 2014-05-23-how-to-add-redirects-to-post-url-on-octopress %}) few month ago. Now [Octopress is compatible](https://github.com/imathis/octopress/commit/72ea6042e33f0b92e4923c3af00e923f19472573) with [Jekyll][] 2.0, and some plugins don't seem to work. Current Octopress uses Jekyll [2.0.3](https://github.com/imathis/octopress/blob/4fdae37e4294618084f652c99c0c06ba7663ac07/Gemfile.lock#L26) and when I run `rake generate`, I see an error:

[Jekyll]: http://jekyllrb.com
[Octopress]: https://github.com/imathis/octopress

``` sh
/path/to/jekyll/lib/jekyll/static_file.rb:40:in `stat': Not a directory @ rb_file_s_stat - /path/to/generated/alias/index.html/ (Errno::ENOTDIR)
```

So I make [this commit](https://github.com/yous/jekyll_alias_generator/commit/7de96759bdd7a2c27fa2d4d603c6c1f585fd2abc):

{% gist 30d45925d0b100052f6d %}

But it seems that there is [another problem](https://github.com/tsmango/jekyll_alias_generator/issues/12) with latest Jekyll, so I make [another commit](https://github.com/yous/jekyll_alias_generator/commit/59a72029307a730014a020dcb3f73506f80ddab5):

{% gist ceb181878cf15b529e6d %}

To say the result first, I had [no luck](https://github.com/yous/yous.github.io/commit/2cf44cbe21b499c89dc8ac68f6f170add52f9d6e). The alias directories are generated, every `index.html` file under each directory won't. By looking at diff of `sitemap.xml`, the plugin seems to generate wrong paths. I'm pretty newbie to Jekyll and how Octopress works with it. Also this is a plugin for Jekyll, not Octopress. So if you have any fix for this problem, please make pull requests to [jekyll_alias_generator](https://github.com/tsmango/jekyll_alias_generator/pulls) or just [contact me](/about/#contact).

<!-- more -->

## <a id="jekyll-redirect-from"></a>jekyll-redirect-from

While searching how to fix this problem, I found [jekyll-redirect-from][] served by Jekyll team. What it does is almost completely same with `jekyll_alias_generator`. Generates alias HTML files when we set `redirect_from` key in YAML front matter of the post.

[jekyll-redirect-from]: https://github.com/jekyll/jekyll-redirect-from

To use this plugin, install `jekyll-redirect-from` gem by select one option from below:

- Add `gem 'jekyll-redirect-from'` to `Gemfile` and execute `bundle`.
- Run `gem install jekyll-redirect-from` on terminal.

Then add it to your `_config.yml`:

``` yaml _config.yml
gems:
    - jekyll-redirect-from
```

Ready to add redirects! You can use this by adding `redirect_from` to the YAML front matter of your page or post:

``` yaml
redirect_from:
    - /path/to/alias/
    - /path/to/another/alias
```

You can also specify just one url:

``` yaml
redirect_from: /path/to/alias/
```

Note that `/path/to/alias/` will generate a `/path/to/alias/index.html`, while `/path/to/alias` will generate a `/path/to/alias`.
