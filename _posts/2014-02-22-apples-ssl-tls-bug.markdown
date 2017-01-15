---
layout: post
title: "Apple's SSL/TLS bug"
date: 2014-02-23 04:59:18 +0900
lang: ko
categories:
    - iOS
description: "애플에서 공개한 iOS 7.0.6 보안 문제의 원인이 흥미롭다."
keywords: ios, 6.1.6, 7.0.6, ssl, tls
redirect_from:
    - /p/20140223/
    - /2014/02/23/apples-ssl-tls-bug/
    - /p/20140222/
external-url: https://www.imperialviolet.org/2014/02/22/applebug.html
---

iOS 7.0.6, iOS 6.1.6, Apple TV 6.0.2가 [배포됐다][9to5Mac]. 애플에서 공개한 iOS 7.0.6의 [보안 문제][security content of iOS 7.0.6]는 다음과 같다.

[9to5Mac]: http://9to5mac.com/2014/02/21/apple-releases-ios-7-0-6-ios-6-1-6-with-fixes/
[security content of iOS 7.0.6]: http://support.apple.com/kb/HT6147

> Impact: An attacker with a privileged network position may capture or modify data in sessions protected by SSL/TLS
>
> Description: Secure Transport failed to validate the authenticity of the connection. This issue was addressed by restoring missing validation steps.

그런데 이 문제의 원인이 된 [소스 코드][sslKeyExchange.c]가 흥미롭다. Adam Langley의 [이 버그에 관한 글][external-url]에 따르면 실제 소스(sslKeyExchange.c)는 이렇다.

[sslKeyExchange.c]: http://opensource.apple.com/source/Security/Security-55471/libsecurity_ssl/lib/sslKeyExchange.c
[external-url]: https://www.imperialviolet.org/2014/02/22/applebug.html

``` c
static OSStatus
SSLVerifySignedServerKeyExchange(SSLContext *ctx, bool isRsa, SSLBuffer signedParams,
                                 uint8_t *signature, UInt16 signatureLen)
{
    OSStatus        err;
    ...

    if ((err = ReadyHash(&SSLHashSHA1, &hashCtx)) != 0)
        goto fail;
    if ((err = SSLHashSHA1.update(&hashCtx, &clientRandom)) != 0)
        goto fail;
    if ((err = SSLHashSHA1.update(&hashCtx, &serverRandom)) != 0)
        goto fail;
    if ((err = SSLHashSHA1.update(&hashCtx, &signedParams)) != 0)
        goto fail;
        goto fail;
    if ((err = SSLHashSHA1.final(&hashCtx, &hashOut)) != 0)
        goto fail;
    ...

fail:
    SSLFreeBuffer(&signedHashes);
    SSLFreeBuffer(&hashCtx);
    return err;

}
```

단지 `goto fail;` 라인이 하나 더 있어서 `if`문과 관계 없이 두 번째 `goto`문이 실행되어 signature verification을 무조건 통과하게 된다.

> Note the two `goto fail` lines in a row. The first one is correctly bound to the if statement but the second, despite the indentation, isn't conditional at all. The code will always jump to the end from that second goto, `err` will contain a successful value because the SHA1 update operation was successful and so the signature verification will never fail.

또한 OS X 10.9.1에는 아직 [이 문제][9to5Mac 2]가 있는 것으로 보인다.

[9to5Mac 2]: http://9to5mac.com/2014/02/22/apple-patched-a-major-ssl-bug-in-ios-yesterday-but-os-x-is-still-at-risk/
