---
layout: post
title: "Gradle 환경에서 ProGuard 사용하기"
date: 2014-05-15 18:11:13 +0900
lang: ko
categories:
    - Android
description: Gradle을 이용해 배포 APK를 생성하는 방법과 함께 ProGuard 사용법을 공유한다.
keywords: gradle, proguard, signed, release, apk, android studio, actionbarsherlock, crashlytics, google play services sdk
redirect_from: /p/20140515/
facebook:
    image: http://yous.be/images/2014/05/15/gradle_logo.gif
twitter_card:
    image: http://yous.be/images/2014/05/15/gradle_logo.gif
---

## Gradle
{: #gradle}

![Gradle](/images/2014/05/15/gradle_logo.gif)

최근 [Android Studio][]를 통해 개발을 진행하게 되면서, 자연스럽게 [Gradle][]을 사용하게 되었다. `.gradle` 확장자를 가진 파일을 통해 빌드 설정을 자유롭게 조정할 수 있다. 이 글에서는 Gradle을 이용해 배포 APK를 생성하는 방법과 함께 [ProGuard][]를 사용법을 공유하겠다.

[Android Studio]: https://developer.android.com/studio
[Gradle]: https://gradle.org
[ProGuard]: https://www.guardsquare.com/en/products/proguard

<!-- more -->

## Gradle 환경에서 배포 APK 생성하기
{: #how-to-create-release-apk-using-gradle}

배포 APK에는 서명이 되어 있어야 하는데, 이를 위해서는 keystore 파일과 그 암호, 키 별칭, 키 암호가 필요하다. 디버그 APK에도 서명을 하지만, [알려진 keystore 암호와 키 별칭, 키 암호][Signing in Debug Mode]를 사용한다. 배포 APK의 서명을 위해 프로젝트의 `build.gradle` 파일에 다음 코드를 추가하면 된다.

[Signing in Debug Mode]: https://developer.android.com/studio/publish/app-signing#debug-mode

``` groovy
android {
    // ...

    signingConfigs {
        release {
            storeFile file("YOUR_KEYSTORE_PATH")
            storePassword "YOUR_KEYSTORE_PASSWORD"
            keyAlias "YOUR_KEY_ALIAS"
            keyPassword "YOUR_KEY_PASSWORD"
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

이때 `buildTypes` 아래의 `debug` 항목은 굳이 명시하지 않아도 [기본적으로 생성][TOC-Build-Types]되며, 이 `buildType`은 [디버그 keystore와 키를 사용하도록 설정][TOC-Signing-Configurations]되어 있다.

[TOC-Build-Types]: http://tools.android.com/tech-docs/new-build-system/user-guide#TOC-Build-Types
[TOC-Signing-Configurations]: http://tools.android.com/tech-docs/new-build-system/user-guide#TOC-Signing-Configurations

다만 이때 `build.gradle` 파일에 keystore 암호와 키 암호가 평문으로 들어가게 되는데, 소스를 공개하고 있는 등의 이유로 이를 피하고 싶다면 각각의 항목을 쉘 프롬프트에서 입력받을 수 있다.

``` groovy
signingConfigs {
    release {
        storeFile file(console.readLine("\n\$ Enter keystore path: "))
        storePassword new String(console.readPassword("\n\$ Enter keystore password: "))
        keyAlias console.readLine("\n\$ Enter key alias: ")
        keyPassword new String(console.readPassword("\n\$ Enter key password: "))
    }
}
```

그러나 이는 [IDE를 통해 디버그 APK를 생성할 때 크래시][How to create a release signed apk file using Gradle?]를 내며, 이는 그때 코드의 `console`이 `null`이라서 발생하는 오류다. 이를 해결한 최종 코드는 다음과 같다.

[How to create a release signed apk file using Gradle?]: https://stackoverflow.com/questions/18328730/how-to-create-a-release-signed-apk-file-using-gradle#19210105

``` groovy
signingConfigs {
    release {
        final Console console = System.console();
        if (console != null) {
            storeFile file(console.readLine("\n\$ Enter keystore path: "))
            storePassword new String(console.readPassword("\n\$ Enter keystore password: "))
            keyAlias console.readLine("\n\$ Enter key alias: ")
            keyPassword new String(console.readPassword("\n\$ Enter key password: "))
        }
    }
}
```

디버그 APK와 배포 APK의 패키지 이름이 같으면 APK의 서명이 서로 달라 개발과 디버깅에 어려움이 있다. 이를 해결하기 위해서 `buildTypes` 아래에 `debug` 항목을 선언하여 디버그 APK의 패키지 이름을 바꿀 수 있고, 추가로 버전명도 바꿀 수 있다.

``` groovy
buildTypes {
    debug {
        packageNameSuffix '.debug'
        versionNameSuffix '-debug'
    }
}
```

이제 터미널에서 다음 명령을 실행하면 디버그 APK와 배포 APK를 각각 얻을 수 있다. 물론 디버그 APK는 IDE로도 생성할 수 있다.

``` sh
$ ./gradlew assembleDebug
$ ./gradlew assembleRelease
```

Gradle은 [캐멀케이스 단축키를 지원][TOC-Android-tasks]해서 `aR`에 해당하는 다른 명령이 없는 한 `assembleRelease` 대신 `aR`을 사용할 수 있다.

[TOC-Android-tasks]: http://tools.android.com/tech-docs/new-build-system/user-guide#TOC-Android-tasks

## ProGuard 사용하기
{: #how-to-use-proguard}

배포 APK를 생성할 때 ProGuard를 사용할 수도 있는데, `build.gradle`에 다음 코드를 추가하면 된다.

``` groovy
buildTypes {
    release {
        runProguard true
        proguardFile getDefaultProguardFile('proguard-android.txt')
    }
}
```

`getDefaultProguardFile()`는 [SDK에 위치한 해당 이름의 파일을 가져와 적용][TOC-Running-ProGuard]한다. `proguard-android.txt`와 `proguard-android-optimize.txt`가 있으며 [앞의 것은 최적화를 수행하지 않고, 뒤의 것은 최적화를 수행][TOC-Running-ProGuard]한다.

[TOC-Running-ProGuard]: http://tools.android.com/tech-docs/new-build-system/user-guide#TOC-Running-ProGuard

추가적인 다른 `proguardFile`을 더 적용하고 싶다면 `proguardFiles`를 사용하면 된다.

``` groovy
buildTypes {
    release {
        runProguard true
        proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-project.txt'
    }
}
```

다른 라이브러리 프로젝트를 가져다 사용하고 있을 경우, ProGuard 사용에 있어 주의해야 한다.

### ActionBarSherlock
{: #actionbarsherlock}

[ActionBarSherlock][]의 경우 ProGuard를 사용할 때, [다음 규칙을 추가하라고 명시][ActionBarSherlock FAQ]하고 있다.

[ActionBarSherlock]: http://actionbarsherlock.com
[ActionBarSherlock FAQ]: http://actionbarsherlock.com/faq.html

```
-keep class android.support.v4.app.** { *; }
-keep interface android.support.v4.app.** { *; }
-keep class com.actionbarsherlock.** { *; }
-keep interface com.actionbarsherlock.** { *; }

-keepattributes *Annotation*
```

### Crashlytics
{: #crashlytics}

[Crashlytics][]는 이미 ProGuard를 사용한 라이브러리들을 다시 ProGuard가 검사할 필요 없게 해서 [빌드 시간을 줄이는 팁][Mastering ProGuard for Building Lightweight Android Code]을 제공하고 있다.

[Crashlytics]: https://try.crashlytics.com
[Mastering ProGuard for Building Lightweight Android Code]: https://fabric.io/blog/2014/02/18/mastering-proguard-for-building-lightweight-android-code

```
-libraryjars libs
-keep class com.crashlytics.** { *; }
```

[Android Support Library][]는 이미 소스가 공개되어 있기 때문에 코드 난독화가 필요하지 않다.

[Android Support Library]: https://developer.android.com/topic/libraries/support-library/

```
-libraryjars libs
-keep class android.support.v4.app.** { *; }
-keep interface android.support.v4.app.** { *; }
```

ProGuard를 이용해 코드 난독화 작업을 거치게 되면, 소스 파일의 줄 번호가 바뀌게 되어 Crashlytics의 스택 트레이스에서 정보를 얻기 어려울 수 있다. [소스 파일의 줄 번호 정보를 유지][Android Studio and IntelliJ with ProGuard]하려면 다음 문장을 추가한다.

[Android Studio and IntelliJ with ProGuard]: https://web.archive.org/web/20161206085850/https://support.crashlytics.com/knowledgebase/articles/202926-android-studio-and-intellij-with-proguard

```
-keepattributes SourceFile,LineNumberTable
```

다만 이 코드 때문에 난독화가 덜 되는 것 같다는 생각이 든다면, 파일 이름을 모두 `"SourceFile"` 문자열로 [바꿀 수도 있다][Producing useful obfuscated stack traces].

[Producing useful obfuscated stack traces]: https://www.guardsquare.com/en/products/proguard/manual/examples#stacktrace

```
-renamesourcefileattribute SourceFile
-keepattributes SourceFile,LineNumberTable
```

### Google Play Services SDK
{: #google-play-services-sdk}

[Google Play Services SDK][] 또한 필요한 클래스가 사라지는 것을 방지하기 위한 [ProGuard 규칙][Create a Proguard Exception]을 제공하고 있다.

[Google Play Services SDK]: https://developers.google.com/android/guides/overview
[Create a Proguard Exception]: https://developer.android.com/google/play-services/setup.html#Proguard

```
-keep class * extends java.util.ListResourceBundle {
    protected Object[][] getContents();
}

-keep public class com.google.android.gms.common.internal.safeparcel.SafeParcelable {
    public static final *** NULL;
}

-keepnames @com.google.android.gms.common.annotation.KeepName class *
-keepclassmembernames class * {
    @com.google.android.gms.common.annotation.KeepName *;
}

-keepnames class * implements android.os.Parcelable {
    public static final ** CREATOR;
}
```

## 참고 목록
{: #see-also}

- [Gradle Plugin User Guide](http://tools.android.com/tech-docs/new-build-system/user-guide) by [Android Tools Project Site](http://tools.android.com)
- [Mastering ProGuard for Building Lightweight Android Code][] by [Crashlytics][]
- [ProGuard Manual](https://www.guardsquare.com/en/products/proguard/manual) by [ProGuard][]
- [Gradle - Progaurd 사용하기(proguard rule)](http://novafactory.net/archives/2845) ([archive](https://web.archive.org/web/20160805062722/http://novafactory.net/archives/2845) by [Nova](https://plus.google.com/113131691466488717287)
