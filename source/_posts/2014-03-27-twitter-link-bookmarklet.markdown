---
layout: post
title: "Twitter Link Bookmarklet"
date: 2014-03-27 10:18:57 +0900
comments: false
description: Dave Bradford의 Twitter Profile Bookmarklet에 추가됐으면 하는 기능이 있어 추가했다.
categories:
    - Tip
keywords: twitter, profile, link, bookmark, bookmarklet
external-url: http://davebradford.com/blog/twitter-profile-bookmarklet/
---

[Dave Bradford][]의 트위터에 관한 팁 [Twitter Profile Bookmarklet][external-url]을 봤다. 직접 써 보니 기능이 추가됐으면 더 좋을 것 같아 추가했다.

[Dave Bradford]: http://davebradford.com/about/
[external-url]: http://davebradford.com/blog/twitter-profile-bookmarklet/

일단, 원글에 있는 코드의 기능은 간단하다. 모바일 사파리를 통해 트위터 계정을 보다가 북마크 버튼을 한 번 누르면 [Tweetbot][]에서 볼 수 있게 된다. 여기에 브라우저를 통해 '트윗'을 보고 있다면 Tweetbot으로 바로 그 트윗을 볼 수 있게 기능을 추가했다. OS X에서도 동일하게 작동한다.

[Tweetbot]: http://tapbots.com/software/tweetbot/

``` javascript
var url = document.URL;
var match = url.match(/status(?:es)?\/(\d+)/i);
var tweetbotUrl;
if (match == null) {
    tweetbotUrl = url.replace(/https?:\/\/(mobile\.)?twitter\.com\//, "tweetbot:///user_profile/");
}
else {
    tweetbotUrl = "tweetbot:///status/" + match[1];
}
window.location = tweetbotUrl;
```

원리는 간단하다. 현재 페이지 URL에 `status`나 `statuses`가 포함되어 있으면 트윗을 열고, 그렇지 않으면 계정을 보여 준다. 아래 코드를 북마크 해두고, 필요할 때 눌러주면 된다.

``` plain
javascript:var%20url=document.URL;var%20match=url.match(/status(?:es)?%5C/(%5Cd+)/i);var%20tweetbotUrl;if(match==null)%7BtweetbotUrl=url.replace(/https?:%5C/%5C/(mobile%5C.)?twitter%5C.com%5C//i,%22tweetbot:///user_profile/%22)%7Delse%7BtweetbotUrl=%22tweetbot:///status/%22+match[1]%7Dwindow.location=tweetbotUrl;
```

기기에 Tweetbot 2와 Tweetbot 3가 모두 깔려 있을 때 Tweetbot 2로 열리는 점은 아쉽다.

via [Yoon Jiman](http://yoonjiman.net/2014/03/25/twitter-profile-bookmarklet/)
