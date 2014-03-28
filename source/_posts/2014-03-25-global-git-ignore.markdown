---
layout: post
title: "Global Git Ignore"
date: 2014-03-25 20:49:32 +0900
comments: false
description: usevim의 Alex Young이 쓴 글이다.
categories:
    - Git
keywords: git, gitignore, global
external-url: http://usevim.com/2013/10/04/gitglobal-ignore/
---

[usevim][]의 [Alex Young][]이 쓴 [global gitignore에 관한 글][external-url]다.

[usevim]: http://usevim.com
[Alex Young]: http://twitter.com/#!/alex_young
[external-url]: http://usevim.com/2013/10/04/gitglobal-ignore/

> 나는 몇 년간 `.gitignore`에 `*.sw?`을 넣어 왔는데, Vim을 쓰지 않는 사람들은 특정 편집기를 위한 `.gitignore` 항목을 보고 싶지 않아 할 수도 있다는 걸 깨달았다. 편집기들은 임시 파일과 복구 파일을 각자 다른 방식으로 관리하기 때문에 이 설정을 모두에게 강요하는 것은 과해 보인다.
>
> 이것보단 global 옵션을 사용하는 것이 낫다. `git config --global core.excludesfile ~/.gitignore`를 실행해라. 그러면 거기에 `*.sw?`을, 어쩌면 `*~`도 넣을 수 있다. 난 `.DS_Store`를 추가할 텐데, Windows 개발자들은 여기 신경 쓸 필요가 없기 때문이다. 그리고 그들은 아마 `Thumbs.db`를 추가해야 할 것이다.
