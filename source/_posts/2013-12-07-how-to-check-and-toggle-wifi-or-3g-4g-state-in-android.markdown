---
layout: post
title: "How to Check and Toggle WiFi or 3G/4G State in Android"
date: 2013-12-07 18:28:05 +0900
comments: true
categories: Android
---

## Overview

1. [Check if WiFi or 3G/4G is Enabled (by User)](#1)
    1. [WiFi](#1-1)
    2. [3G/4G](#1-2)
2. [Check if WiFi or 3G/4G is Connected](#2)
    1. [WiFi](#2-1)
    2. [3G/4G](#2-2)
3. [Toggle WiFi or 3G/4G Programmatically](#3)
    1. [WiFi](#3-1)
    2. [3G/4G](#3-2)

At some point, we want to know whether the device is connected to network so that we can do some network processes. Also we want to know if _user_ make WiFi or 3G/4G disabled on purpose. Both things are able to know.

<!-- more -->

<a id="1"></a>
## 1. Check if WiFi or 3G/4G is Enabled (by User)

<a id="1-1"></a>
### WiFi

`ACCESS_WIFI_STATE` permission must be added to `AndroidManifest.xml`.

{% codeblock AndroidManifest.xml %}
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
{% endcodeblock %}

Checking code is simple. In activity, [WifiManager][] has a handy method.

[WifiManager]: http://developer.android.com/reference/android/net/wifi/WifiManager.html

{% codeblock lang:java %}
WifiManager wifiManager = (WifiManager) getSystemService(WIFI_SERVICE);
boolean wifiEnabled = wifiManager.isWifiEnabled();
{% endcodeblock %}

<a id="1-2"></a>
### 3G/4G

This is more complicated. As WiFi case, we have to add `ACCESS_NETWORK_STATE` permission.

{% codeblock AndroidManifest.xml %}
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
{% endcodeblock %}

Then we get [NetworkInfo][] from [ConnectivityManager][].

[NetworkInfo]: http://developer.android.com/reference/android/net/NetworkInfo.html
[ConnectivityManager]: http://developer.android.com/reference/android/net/ConnectivityManager.html

{% codeblock lang:java %}
ConnectivityManager connectivityManager =
    (ConnectivityManager) getSystemService(CONNECTIVITY_SERVICE);
NetworkInfo mobileInfo =
    connectivityManager.getNetworkInfo(ConnectivityManager.TYPE_MOBILE);
{% endcodeblock %}

See [getState()][] overview.

> Reports the current coarse-grained state of the network.

[getState()]: http://developer.android.com/reference/android/net/NetworkInfo.html#getState()

There are 6 types of [NetworkInfo.State][].

- `CONNECTED`
- `CONNECTING`
- `DISCONNECTED`
- `DISCONNECTING`
- `SUSPENDED`
- `UNKNOWN`

[NetworkInfo.State]: http://developer.android.com/reference/android/net/NetworkInfo.State.html

Also this is [getReason()][] overview.

> Report the reason an attempt to establish connectivity failed, if one is available.

[getReason()]: http://developer.android.com/reference/android/net/NetworkInfo.html#getReason()

We can realize that when `NetworkInfo.State` is `DISCONNECTED`, `getReason()` reports to us why mobile data is disconnected.

Also I tested several times with `getState()` and `getReason()`.

- Enable WiFi and 3G/4G

  When WiFi is connected, mobile data connection automatically closed.

{% codeblock lang:java %}
mobileInfo.getState()
// => DISCONNECTED
mobileInfo.getReason()
// => "dataDisabled"
{% endcodeblock %}

- Enable WiFi only

{% codeblock lang:java %}
mobileInfo.getState()
// => DISCONNECTED
mobileInfo.getReason()
// => "specificDisabled"
{% endcodeblock %}

- Enable 3G/4G only

{% codeblock lang:java %}
mobileInfo.getState()
// => CONNECTED
{% endcodeblock %}

- Disable both

{% codeblock lang:java %}
mobileInfo.getState()
// => DISCONNECTED
mobileInfo.getReason()
// => "specificDisabled"
{% endcodeblock %}

So the code would be like this.

{% codeblock lang:java %}
String reason = mobileInfo.getReason();
boolean mobileDisabled = mobileInfo.getState() == NetworkInfo.State.DISCONNECTED
    && (reason == null || reason.equals("specificDisabled"));
{% endcodeblock %}

<a id="2"></a>
## 2. Check if WiFi or 3G/4G is Connected

WiFi or 3G/4G may not be connected even if the user enables them. Checking connectivity is useful when we are going to do some network communication.

<a id="2-1"></a>
### WiFi

{% codeblock lang:java %}
NetworkInfo wifiInfo =
    connectivityManager.getNetworkInfo(ConnectivityManager.TYPE_WIFI);
boolean wifiConnected = wifiInfo.getState() == NetworkInfo.State.CONNECTED;
{% endcodeblock %}

<a id="2-2"></a>
### 3G/4G

{% codeblock lang:java %}
NetworkInfo mobileInfo =
    connectivityManager.getNetworkInfo(ConnectivityManager.TYPE_MOBILE);
boolean mobileConnected = mobileInfo.getState() == NetworkInfo.State.CONNECTED;
{% endcodeblock %}

<a id="3"></a>
## 3. Toggle WiFi or 3G/4G Programmatically

<a id="3-1"></a>
### WiFi

`CHANGE_WIFI_STATE` permission must be added to `AndroidManifest.xml`.

{% codeblock AndroidManifest.xml %}
<uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />
{% endcodeblock %}

Enabling or disabling WiFi is easy.

{% codeblock lang:java %}
WifiManager wifiManager = (WifiManager) getSystemService(WIFI_SERVICE);
wifiManager.setWifiEnabled(isWifiEnabled);
{% endcodeblock %}

<a id="3-2"></a>
### 3G/4G

There is an workaround with reflection on ["How can i turn off 3G/Data programmatically on Android?"][Stack Overflow].

[Stack Overflow]: http://stackoverflow.com/questions/12535101/how-can-i-turn-off-3g-data-programmatically-on-android#12535246

For Android 2.3 and above:

{% codeblock lang:java %}
private void setMobileDataEnabled(Context context, boolean enabled) {
  final ConnectivityManager conman =
      (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
  try {
    final Class conmanClass = Class.forName(conman.getClass().getName());
    final Field iConnectivityManagerField = conmanClass.getDeclaredField("mService");
    iConnectivityManagerField.setAccessible(true);
    final Object iConnectivityManager = iConnectivityManagerField.get(conman);
    final Class iConnectivityManagerClass = Class.forName(
        iConnectivityManager.getClass().getName());
    final Method setMobileDataEnabledMethod = iConnectivityManagerClass
        .getDeclaredMethod("setMobileDataEnabled", Boolean.TYPE);
    setMobileDataEnabledMethod.setAccessible(true);

    setMobileDataEnabledMethod.invoke(iConnectivityManager, enabled);
  } catch (ClassNotFoundException e) {
    e.printStackTrace();
  } catch (InvocationTargetException e) {
    e.printStackTrace();
  } catch (NoSuchMethodException e) {
    e.printStackTrace();
  } catch (IllegalAccessException e) {
    e.printStackTrace();
  } catch (NoSuchFieldException e) {
    e.printStackTrace();
  }
}
{% endcodeblock %}

It requires to `CHANGE_NETWORK_STATE` permission.

{% codeblock AndroidManifest.xml %}
<uses-permission android:name="android.permission.CHANGE_NETWORK_STATE" />
{% endcodeblock %}

In Activity:

{% codeblock lang:java %}
setMobileDataEnabled(this, isMobileDataEnabled);
{% endcodeblock %}

Codes for Android 2.2 and below are also in the same [link][Stack Overflow], but I didn't check it.
