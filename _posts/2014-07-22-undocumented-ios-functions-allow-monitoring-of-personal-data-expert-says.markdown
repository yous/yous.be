---
layout: post
title: "Undocumented iOS functions allow monitoring of personal data, expert says"
date: 2014-07-22 22:19:14 +0900
comments: false
categories:
    - iOS
description: "&#34;Backdoor&#34; can be abused by gov't agents and ex-lovers to gain persistent access."
keywords: ios, back door, com.apple.mobile.file_relay, com.apple.pcapd, com.apple.mobile.house_arrest, diagnostic capabilities
redirect_from: /p/20140722/
external-url: http://arstechnica.com/security/2014/07/undocumented-ios-functions-allow-monitoring-of-personal-data-expert-says/
twitter_card:
    image: http://yous.be/images/2014/07/22/pcapd1.jpg
facebook:
    image: http://yous.be/images/2014/07/22/pcapd1.jpg
---

> "Backdoor" can be abused by gov't agents and ex-lovers to gain persistent access.
>
> Apple has endowed iPhones with undocumented functions that allow unauthorized people in privileged positions to wirelessly connect and harvest pictures, text messages, and other sensitive data without entering a password or PIN, a forensic scientist warned over the weekend.
>
> Zdziarski said the service that raises the most concern is known as com.apple.mobile.file_relay. It dishes out a staggering amount of data---including account data for e-mail, Twitter, iCloud, and other services, a full copy of the address book including deleted entries, the user cache folder, logs of geographic positions, and a complete dump of the user photo album---all without requiring a backup password to be entered. He said two other services dubbed com.apple.pcapd and com.apple.mobile.house_arrest may have legitimate uses for app developers or support people but can also be used to spy on users by government agencies or even jilted ex-lovers. The Pcapd service, for instance, allows people to wirelessly monitor all network traffic traveling into and out of the device, even when it's not running in a special developer or support mode. House_arrest, meanwhile, allows the copying of sensitive files and documents from Twitter, Facebook, and many other applications.
>
> ![com.apple.pcapd](/images/2014/07/22/pcapd1.jpg "com.apple.pcapd")
>
> Slides of Zdziarski's talk, titled **Identifying Back Doors, Attack Points, and Surveillance Mechanisms in iOS Devices** are [here](https://pentest.com/ios_backdoors_attack_points_surveillance_mechanisms.pdf).

Also check the page about [iOS: About diagnostic capabilities](http://support.apple.com/kb/HT6331) on Apple Support:

> Each of these diagnostic capabilities requires the user to have unlocked their device and agreed to trust another computer. Any data transmitted between the iOS device and trusted computer is encrypted with keys not shared with Apple. For users who have enabled iTunes Wi-Fi Sync on a trusted computer, these services may also be accessed wirelessly by that computer.
