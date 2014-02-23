---
layout: post
title: "Octopress in a subdirectory: /blog"
date: 2013-08-12 06:08
comments: false
categories:
    - Octopress
keywords: octopress, subdirectory
---

Octopress 블로그를 사이트 루트가 아닌 하위 디렉토리에서 제공하고 싶을 때, 터미널에서 다음과 같이 실행해 줍니다.

{% codeblock lang:bash %}
rake set_root_dir[/blog]

# To go back to publishing to the document root
rake set_root_dir[/]
{% endcodeblock %}

그리고 `_config.yml`을 수정해 줍니다.

{% codeblock _config.yml lang:yml %}
# url: http://yoursite.com
url: http://yoursite.com/blog
{% endcodeblock %}

추가로, `/blog`를 하위 디렉토리로 사용했을 때, Archives와 Categories, 그리고 포스트 경로들이 `http://yoursite.com/blog/blog/...`의 형태로 생성됩니다. 중복된 `/blog`를 지우기 위해 다음과 같이 설정을 변경해 줍니다.

{% codeblock _config.yml lang:yml %}
# permalink: /blog/:year/:month/:day/:title/
permalink: /:year/:month/:day/:title/

# category_dir: blog/categories
category_dir: categories
{% endcodeblock %}

{% codeblock source/_includes/custom/navigation.html lang:html %}
<!--
<li><a href="{{ root_url }}/blog/archives">Archives</a></li>
-->
<li><a href="{{ root_url }}/archives">Archives</a></li>
{% endcodeblock %}

그리고, `source/blog/archives` 폴더를 `source/archives`로 옮겨주시기 바랍니다.

{% codeblock source/index.html lang:html %}
<!--
<a href="/blog/archives">Blog Archives</a>
-->
<a href="/archives">Blog Archives</a>
{% endcodeblock %}

사용중인 테마에 따라 추가적인 수정 사항이 있을 수 있습니다.
