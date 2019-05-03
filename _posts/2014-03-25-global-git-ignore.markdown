---
layout: post
title: "Global Git Ignore"
date: 2014-03-25 20:49:32 +0900
lang: ko
categories:
    - Git
description: usevim의 Alex Young이 쓴 global gitignore에 관한 글이다.
keywords: git, gitignore, global
redirect_from: /p/20140325/
external-url: https://medium.com/usevim/global-git-ignore-74f7fe424784
---

[usevim][]의 [Alex Young][]이 쓴 [global gitignore에 관한 글][external-url]이다.

[usevim]: https://medium.com/usevim
[Alex Young]: https://medium.com/@alex_young
[external-url]: https://medium.com/usevim/global-git-ignore-74f7fe424784

<!-- For years I dumped this into my `.gitignore` files: `*.sw?`. Then I realised that some people don't use Vim, and therefore probably don't want to see my editor-specific `.gitignore` entries. Different editors handle swap and recovery files different ways, so it seems redundant to force these settings on everyone. -->
> 나는 몇 년간 `.gitignore`에 `*.sw?`을 넣어 왔는데, Vim을 쓰지 않는 사람들은 특정 편집기를 위한 `.gitignore` 항목을 보고 싶지 않아 할 수도 있다는 걸 깨달았다. 편집기들은 임시 파일과 복구 파일을 각자 다른 방식으로 관리하기 때문에 이 설정을 모두에게 강요하는 것은 과해 보인다.
>
<!-- A better approach is to use a global option. Run `git config --global core.excludesfile ~/.gitignore`. Then you can add `*.sw?`, and perhaps `*~` as well. I like to add `.DS_Store` because Windows developers don't need to worry about that nonsense, and they should probably add `Thumbs.db`. -->
> 이것보단 global 옵션을 사용하는 것이 낫다. `git config --global core.excludesfile ~/.gitignore`를 실행해라. 그러면 거기에 `*.sw?`을, 어쩌면 `*~`도 넣을 수 있다. 난 `.DS_Store`를 추가할 텐데, Windows 개발자들은 여기 신경 쓸 필요가 없기 때문이다. 그리고 그들은 아마 `Thumbs.db`를 추가해야 할 것이다.
