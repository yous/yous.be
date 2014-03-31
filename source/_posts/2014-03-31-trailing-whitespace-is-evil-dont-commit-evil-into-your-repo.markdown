---
layout: post
title: "Trailing whitespace is evil. Don't commit evil into your repo."
date: 2014-03-31 20:57:09 +0900
comments: false
categories:
    - Git
keywords: trailing, whitespace, git
external-url: http://codeimpossible.com/2012/04/02/Trailing-whitespace-is-evil-Don-t-commit-evil-into-your-repo-/
---

[Jared Barboza][]가 쓴 [줄 끝 공백에 관한 글][external-url]이다.

[Jared Barboza]: http://codeimpossible.com/about.html
[external-url]: http://codeimpossible.com/2012/04/02/Trailing-whitespace-is-evil-Don-t-commit-evil-into-your-repo-/

> **난 최근에 다양한 사람/언어/편집기와 함께 많은 프로젝트를 진행해 왔다. 우리들 대부분은 Git 초보자였고, 각 프로젝트는 줄 끝 공백에 관한 진짜 문제가 있었다.**

경력 있는 개발자로만 이루어진 팀이라고 해도 이런 문제는 발생하기 마련이다.

> 줄 끝 공백은 당신의 저장소에서 상당히 많은 문제를 일으킬 수 있다. 실제로 바뀐 것은 공백일 뿐인데도 그 줄에 변경 사항이 있다는 잘못된 diff를 만든다.
>
> 이는 개발 과정에서 나중에 실제 파일의 변경 사항이 무엇이었는지 찾기 불가능하게 만든다. 대부분의 오픈 소스 프로젝트 대표들은 이를 알고 있고, 그들 대부분은 줄 끝 공백을 없애지 않은 풀 리퀘스트를 거절할 것이다.

이후 글에서는 Visual Studio와 Sublime Text 2에서 줄 끝 공백을 제거하는 방법과 git hook을 통해 커밋에 줄 끝 공백이 포함되지 않도록 하는 방법을 소개하고 있다.

나는 Android Studio에서는 파일 저장 시 모든 줄 끝 공백을 지우고, Vim에서는 줄 끝 공백에 하이라이트를 입혀 쓰고 있다.

``` vim .vimrc
highlight ExtraWhitespace ctermbg=red guibg=red
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace //
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
if version >= 702
  autocmd BufWinLeave * call clearmatches()
end
```
