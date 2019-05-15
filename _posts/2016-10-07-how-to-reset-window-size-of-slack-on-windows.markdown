---
layout: post
title: "How to reset window size of Slack on Windows"
date: 2016-10-07 12:07:02 +0000
categories:
    - Technology
description: "It shrinked accidently!"
keywords: reset, window size, slack, windows
redirect_from: /p/20161007/
twitter_card:
    image: https://yous.be/images/2016/10/07/slack-2.2.1.png
facebook:
    image: https://yous.be/images/2016/10/07/slack-2.2.1.png
---

## Slack application

[Slack](https://slack.com/), you may know. It rocks, and I'm also involved in
several teams. Their site is great, but more teams, more tabs in my browser. I
decided to use their Windows app which provides handy shortcuts for switching
between teams.

Today I just remotely connected to my Windows desktop from my notebook. But
then, I realized the Slack window is shrinked. Maybe the reason is my notebook's
screen size, but I don't know. Its content area became too small to read, so I
wanted its window size back.

Actually the default window size was my taste, so I wanted to just reset its
customized window size. And I found it, so here I am to share with you.

## Resetting Slack's window size

### Slack 2.2.1

First of all, note that this is not the permanent solution since it's not a part
of Slack API or something that is guaranteed by them. My Windows machine is
64-bit and the version of Slack is 2.2.1.

![Slack 2.2.1](/images/2016/10/07/slack-2.2.1.min.png "Slack 2.2.1")

So here is a way to resetting the window size of Slack.

1. Quit your Slack application.
2. Navigate to `%APPDATA%\Slack`. The value of `%APPDATA%` is something like
   `C:\Users\{username}\AppData\Roaming`.
3. Open `redux-state.json` to edit.
4. Find `windowSettings` under `state`'s `app`. Its value would be like:

   ``` json
   \"windowSettings\":{\"size\":[1152,832],\"position\":[384,104],\"isMaximized\":false}
   ```
5. Delete the whole `windowSettings` entry above. If you delete only a part of
   value of `windowSettings`, application may crash.
6. Open Slack again. It will set the default window size automatically.

### Slack 2.4.1, 3.3.3

With updates of Slack, settings related to window were separated and moved to
another location. Here is a way to resetting the window size:

1. Quit your Slack application.
2. Navigate to `%APPDATA%\Slack\storage`. The value of `%APPDATA%` is something
   like `C:\Users\{username}\AppData\Roaming`.
3. Open `slack-windowFrame` to edit.
4. Delete the whole content, but do not delete the file itself.
5. Open Slack again. It will set the default window size automatically.

Keep calm and use Slack!
