---
layout: post
title: "How to Add Redirects to Post URL on Octopress"
date: 2014-05-23 14:56:44 +0900
comments: false
description: Adding redirect urls to post using jekyll_alias_generator on Octopress.
categories:
    - Octopress
keywords: redirect, alias, shortcut, octopress, jekyll, alias generator
redirect_from: /p/20140523/
---

When I write a new post on [Octopress][], I share the link of it to somewhere doesn't support [hyperlinks][Hyperlink]. Since people can't click the link, they should copy and paste or just type it letter by letter. I wanted to make it easier, so I maded short url for every post.

[Octopress]: http://octopress.org
[Hyperlink]: http://en.wikipedia.org/wiki/Hyperlink

## <a id="alias-generator-for-posts"></a>Alias Generator for Posts

There is a [Jekyll][] plugin that [generates redirect pages for posts with aliases][jekyll_alias_generator]. Octopress is based on Jekyll and this plugin has no compatibility problem. Its source is on GitHub, so I just added it as submodule:

[Jekyll]: http://jekyllrb.com
[jekyll_alias_generator]: https://github.com/tsmango/jekyll_alias_generator

``` sh
$ git submodule add git@github.com:tsmango/jekyll_alias_generator plugins/jekyll_alias_generator
```

In your `_config.yml`, you may have this line:

``` yaml
plugins: plugins
```

Then it reads `plugins` directory and `alias_generator.rb` in `plugins/jekyll_alias_generator/_plugins/` directory is also loaded, so you can use and manage it!


## <a id="how-to-use"></a>How to Use

This plugin checks `alias` inside every post's YAML Front Matter. Just place the path of the alias:

``` yaml
---
layout: post
title: "How to Add Redirects to Post URL on Octopress"
alias: /p/20140523
---
```

Multiple aliases are also available:

``` yaml
---
layout: post
title: "How to Add Redirects to Post URL on Octopress"
alias: [/one-alias/index.html, /another-alias/index.html]
---
```

When I `rake generate`, the plugin generates static html file at `/p/20140523/index.html`:

``` html
<!DOCTYPE html>
<html>
<head>
<link rel="canonical" href="/2014/05/23/how-to-add-redirects-to-post-url-on-octopress/"/>
<meta http-equiv="content-type" content="text/html; charset=utf-8" />
<meta http-equiv="refresh" content="0;url=/2014/05/23/how-to-add-redirects-to-post-url-on-octopress/" />
</head>
</html>
```

When you go to [/p/20140523](/p/20140523), it will redirect here. It also has [canonical link][Canonical_link_element], so it won't affect search engine or web analysis services.

[Canonical_link_element]: http://en.wikipedia.org/wiki/Canonical_link_element
