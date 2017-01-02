---
layout: post
title: "Fragment Transaction & Activity State Loss"
date: 2014-04-03 00:03:50 +0900
lang: ko
comments: false
description: FragmentTransaction을 commit 했을 때 나타나는 IllegalStateException의 원인이 무엇인지, 어떻게 이를 피할지, 그리고 commitAllowingStateLoss가 왜 마지막 수단이 되어야 하는지 잘 설명한 글이 있어 소개한다.
categories:
    - Android
keywords: android, fragment, transaction, commit, state, loss, commitallowingstateloss
redirect_from:
    - /p/20140403/
    - /2014/04/03/fragment-transaction-and-activity-state-loss/
    - /p/20140402/
external-url: http://www.androiddesignpatterns.com/2013/08/fragment-transaction-commit-state-loss.html
---

[FragmentTransaction][]을 [commit()][] 했을 때 Activity의 [onSaveInstanceState(Bundle)][]이 실행된 후라면 다음과 같은 에러 메시지를 보게 된다.

```
java.lang.IllegalStateException: Can not perform this action after onSaveInstanceState
```

[FragmentTransaction]: http://developer.android.com/reference/android/support/v4/app/FragmentTransaction.html
[commit()]: http://developer.android.com/reference/android/support/v4/app/FragmentTransaction.html#commit()
[onSaveInstanceState(Bundle)]: http://developer.android.com/reference/android/app/Activity.html#onSaveInstanceState(android.os.Bundle)

이 문제의 원인이 무엇인지, 어떻게 이 Exception을 피할지, 그리고 [commitAllowingStateLoss()][]가 왜 마지막 수단이 되어야 하는지 잘 설명한 글이 있어 소개한다. [Alex Lockwood][]가 쓴 [Fragment Transaction과 Activity State Loss][external-url]에 관한 글이다.

[commitAllowingStateLoss()]: http://developer.android.com/reference/android/support/v4/app/FragmentTransaction.html#commitAllowingStateLoss()
[Alex Lockwood]: http://www.androiddesignpatterns.com/about/
[external-url]: http://www.androiddesignpatterns.com/2013/08/fragment-transaction-commit-state-loss.html
