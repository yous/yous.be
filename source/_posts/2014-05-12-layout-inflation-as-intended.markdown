---
layout: post
title: "Layout Inflation as Intended"
date: 2014-05-12 07:17:37 +0900
comments: false
description: 바른 Layout Inflation 방법에 대해 설명해 놓은 Dave Smith의 글이 있어 소개한다.
categories:
    - Android
keywords: android, layout, inflate, inflation, root, parent, container, null
alias: /p/20140512
external-url: http://www.doubleencore.com/2013/05/layout-inflation-as-intended/
---

안드로이드 개발을 하다 보면 [LayoutInflater][]의 [inflate(int, ViewGroup)][]와 [inflate(int, ViewGroup, boolean)][]는 꽤 익숙하다. 하지만 다음 두 줄의 코드가 어떻게 다른지 아는 사람은 그리 많지 않을 것 같다. 실제로 [Android Lint][]는 한쪽 코드는 피하도록 권하고 있다.

[LayoutInflater]: http://developer.android.com/reference/android/view/LayoutInflater.html
[inflate(int, ViewGroup)]: http://developer.android.com/reference/android/view/LayoutInflater.html#inflate(int,%20android.view.ViewGroup)
[inflate(int, ViewGroup, boolean)]: http://developer.android.com/reference/android/view/LayoutInflater.html#inflate(int,%20android.view.ViewGroup,%20boolean)
[Android Lint]: http://tools.android.com/tips/lint

``` java
inflater.inflate(R.layout.my_layout, null);
inflater.inflate(R.layout.my_layout, parent, false);
```

[Dave Smith][]가 이 두 코드의 비교와 함께, [바른 Layout Inflation 방법][external-url]에 대해 설명한 글이 있어 소개한다.

[Dave Smith]: http://www.doubleencore.com/author/daves/
[external-url]: http://www.doubleencore.com/2013/05/layout-inflation-as-intended/
