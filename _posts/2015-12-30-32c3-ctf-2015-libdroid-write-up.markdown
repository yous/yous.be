---
layout: post
title: "32C3 CTF 2015: libdroid Write-up"
date: 2015-12-30 16:59:51 +0000
categories:
    - CTF
description: "Write-up of 32C3 CTF 2015: libdroid."
keywords: 32c3, 32c3 ctf 2015, libdroid, android, write-up
redirect_from: /p/20151230/
twitter_card:
    image: http://yous.be/images/2015/12/30/jd-gui.png
facebook:
    image: http://yous.be/images/2015/12/30/jd-gui.png
---

## Reversing (150)

> Solves: 17
>
> Please install [this](https://32c3ctf.ccc.ac/uploads/libdroid_fixed.tar.gz) on
> your new android phone, enter pass code and get the flag.
>
> **Hints:**
>
> - Updated the libdroid.apk, this one is now also able to run on a device. No
>   changes to internal logic.

If the above link doesn't work, please use this
[link](/downloads/2015/12/30/libdroid_fixed.tar.gz).

<!-- more -->

### Decompiling the APK

First things first, rename the `libdroid_fixed.apk` to `libdroid_fixed.zip` and
unzip it. Then there should be a `classes.dex` file, and we have
[dex2jar](https://sourceforge.net/projects/dex2jar/).

On Windows,

``` sh
d2j-dex2jar.bat classes.dex
```

Otherwise,

``` sh
dsj-dex2jar.sh classes.dex
```

Then we can obtain `classes-dex2jar.jar`, now it's
[JD-GUI](http://jd.benow.ca/)'s turn. Open the jar file with JD-GUI and you will
see the content of class `ctf.stratumauhhur.libdroid.a`.

![JD-GUI](/images/2015/12/30/jd-gui.min.png "JD-GUI")

The full content of the `a.class` is available on
[this gist](https://gist.github.com/yous/43bc6f60d41d0197cf18).

There are quite many methods with name `a` in class
`ctf.stratumauhhur.libdroid.a`:

``` java
static String a(String paramString, int paramInt) {...}
public void a(View paramView) {...}
void a(String paramString) {...}
byte[] a(byte[] paramArrayOfByte, String paramString) {...}
```

At first, static variables of the class are assigned, and since the class is an
activity, `protected void onCreate(Bundle paramBundle)` should be called.

The following is the code assigning static variables:

``` java
static String a;
static String b;
static String c;
static String d;
static String f;
static String flag = a(getFlag(), 1);
static String g;
String e;

static
{
  System.loadLibrary("libdroid");
  a = a(getOperatingSystem(), 1);
  b = a(getPhoneNumber(), 1);
  c = a(installRootkit(), 1);
  d = a(generateConfusion(), 1);
  f = a(obtainWorldDomination(), 1);
  g = a(installiOS(), 1);
}
```

The method `static String a(String paramString, int paramInt)` is used for the
static variables, and `getFlag()`, `getOperatingSystem()`, `getPhoneNumber()`,
`installRootkit()`, `generateConfusion()`, `obtainWorldDomination()`,
`installiOS()` are native methods.

We should look into the `static String a(String paramString, int paramInt)`. See
the following lines:

``` java
Object localObject1 = new Exception().getStackTrace()[paramInt];
Object localObject2 = new StringBuilder();
((StringBuilder)localObject2).append(((StackTraceElement)localObject1).getClassName()).insert(paramInt, ((StackTraceElement)localObject1).getMethodName());
localObject1 = localObject2.toString();
```

The `paramInt` is always 1, so `localObject1` is `new
Exception().getStackTrace()[1]`, and it's the name of class is
`ctf.stratumauhhur.libdroid.a`, and the name of method is `<clinit>`. So, the
value of `localObject1` will be `"c<clinit>tf.stratumauhhur.libdroid.a"`.

### The native methods

To know the behavior of native methods, we should decompile
`lib/x86/liblibdroid.so` file using IDA, OllyDbg, or something. By looking into
it, we can easily know that the native methods just return constant string. This
piece of Ruby code will translate them.

``` ruby
def a(str, int)
  obj1 = 'c<clinit>tf.stratumauhhur.libdroid.a'
  obj2 = [0] * str.size
  i = 0
  int = obj1.size
  loop do
    if i < str.size
      j = str[i].ord
      obj2[i] = (obj1[int - 1].ord ^ j ^ 0x12)
      i += 1
      if i >= str.size
        return obj2.select { |v| v != 0 }.map(&:chr).join
      end
    else
      return obj2.select { |v| v != 0 }.map(&:chr).join
    end
    j = str[i].ord
    obj2[i] = (obj1[int - 1].ord ^ j ^ 0xFA)
    int -= 1
    i += 1
    if int <= 0
      int = obj1.size
    end
  end
end

getOperatingSystem = "\x10\xF4\x52\xB2\x1F\xF9\x55\xFA\x13\xFC".bytes
getPhoneNumber = "\x11\xF7\x5D\xB6\x1A\xFF\x19\xFF\x1C\xF7\x0C\xE9".bytes
generateConfusion = "\x53\xAA\x0E\xE7\x42\xAB\x4D\xA4\x45\xAC\x50".bytes
getFlag = "\x20\xF4\x4E\xA6\x0F\xBE\x15\xFC\x5D\xE7\x0F\xE7\x02\xF5\x19\xEC\x5B\xF5\x11\xE4\x1C\xAD\x0F\xFD\x47\xB5\x52".bytes
installRootkit = "\x30\xF4\x52\xB3\x04\xFF\x0F\xE6\x11\xF4".bytes
obtainWorldDomination = "\x18\xFE\x45\xE9".bytes
installiOS = "\x01\xF4\x53\xA0\x1D\xF7\x0F\xAE".bytes

_flag = a(getFlag, 1)
# => "Sorry no rootkit for you :("
_a = a(getOperatingSystem, 1)
# => "config.ini"
_b = a(getPhoneNumber, 1)
# => "blablablabla"
_c = a(installRootkit, 1)
# => "Congratula"
_d = a(generateConfusion, 1)
# => " 1234567890"
_f = a(obtainWorldDomination, 1)
# => "key="
_g = a(installiOS, 1)
# => "rootkit="
```

### Decompiling `onCreate`

Now we have static variables, so the next thing is `protected void
onCreate(Bundle paramBundle)`:

``` java
protected void onCreate(Bundle paramBundle)
{
  super.onCreate(paramBundle);
  setContentView(2130968601);
  try
  {
    a(a);
    this.e = "";
    return;
  }
  catch (Exception paramBundle)
  {
    for (;;) {}
  }
}
```

The method is `void a(String paramString)`, and the variable `a` is static
variable that we have calculated right before, which is `"config.ini"`. Then let's look into the method.

``` java
void a(String paramString)
  throws Exception
{
  paramString = getAssets().open(paramString);
  Object localObject = new ByteArrayOutputStream();
  byte[] arrayOfByte = new byte[0x4000];
  for (;;)
  {
    int i = paramString.read(arrayOfByte, 0, arrayOfByte.length);
    if (i == -1) {
      break;
    }
    ((ByteArrayOutputStream)localObject).write(arrayOfByte, 0, i);
  }
  ((ByteArrayOutputStream)localObject).flush();
  paramString = new BufferedReader(new InputStreamReader(new ByteArrayInputStream(a(((ByteArrayOutputStream)localObject).toByteArray(), b))));
  for (;;)
  {
    localObject = paramString.readLine();
    if (localObject == null) {
      break;
    }
    if (((String)localObject).startsWith(g)) {
      g = ((String)localObject).substring(g.length());
    }
    if (((String)localObject).startsWith((String)f)) {
      f = (byte[])Base64.decode(((String)localObject).substring(((String)f).length()), 0);
    }
  }
}
```

It reads an asset with its name `paramString` into `localObject`, and then
execute `byte[] a(byte[] paramArrayOfByte, String paramString)` with
`localObject` and `b`.

Again, this is the Ruby version of the code. You can find `config.ini` in the
`assets` directory.

``` ruby
def byte_a(paramArrayOfByte, paramString)
  arrayOfByte = [0] * paramArrayOfByte.size
  arrayOfByte.size.times do |i|
    arrayOfByte[i] = (paramArrayOfByte[i].ord ^ paramString[i % paramString.size].ord)
  end
  arrayOfByte.map(&:chr).join
end

config_ini = "^\x1E\x0E\r\x18_h\a\x04\eQ(3/&\x16CJ%40;\x18,#Q\\h\x1E\x0E\r" \
  "\x18\n\v\x18\\\x03C\x05M\x0FN\x01B\x05\x03\x18k^C\x13\r\x03\x15\\"
puts paramString = byte_a(config_ini, _b)
# <root>
# key=IQCGt/+GXQYtMA==
# rootkit=a/d/c/c.dat
# </root>
```

So `g` will be replaced with `"a/d/c/c.dat"`, and `f` will be replaced with
the value of `Base64.decode("IQCGt/+GXQYtMA==")`, which is
`"!\x00\x86\xB7\xFF\x86]\x06-0"`.

### The main logic

Now we're almost close. There's only `public void a(View paramView)` left to
analyze.

``` java
if (paramView.getId() == 2131492969) {
  this.e += d.charAt(1);
}
if (paramView.getId() == 2131492970) {
  this.e += d.charAt(2);
}
if (paramView.getId() == 2131492971) {
  this.e += d.charAt(3);
}
if (paramView.getId() == 2131492972) {
  this.e += d.charAt(4);
}
if (paramView.getId() == 2131492973) {
  this.e += d.charAt(5);
}
if (paramView.getId() == 2131492974) {
  this.e += d.charAt(6);
}
if (paramView.getId() == 2131492975) {
  this.e += d.charAt(7);
}
if (paramView.getId() == 2131492977) {
  this.e += d.charAt(8);
}
if (paramView.getId() == 2131492978) {
  this.e += d.charAt(9);
}
if (paramView.getId() == 2131492976) {
  this.e += d.charAt(0);
}
```

Obviously, this handles a button click. `d` is `" 1234567890"`, so we can think
the button 1 to 9 is mapped to `"1"` to `"9"` respectively, and the button 0 is
mapped to `" "`.

``` java
String str;
Object localObject2;
Object localObject1;
if ((this.e.length() == 6) || (paramView.getId() == 2131492979))
{
  str = flag;
  try
  {
    InputStream localInputStream = getAssets().open(g);
    localObject2 = new ByteArrayOutputStream();
    byte[] arrayOfByte = new byte[0x4000];
    for (;;)
    {
      int i = localInputStream.read(arrayOfByte, 0, arrayOfByte.length);
      if (i == -1) {
        break;
      }
      ((ByteArrayOutputStream)localObject2).write(arrayOfByte, 0, i);
    }
    Snackbar.make(paramView, (CharSequence)localObject1, 0).setAction("Action", null).show();
  }
  catch (Exception localException)
  {
    localException.printStackTrace();
    localObject1 = str;
  }
}
for (;;)
{
  this.e = "";
  return;
  ((ByteArrayOutputStream)localObject2).flush();
  localObject2 = ((ByteArrayOutputStream)localObject2).toByteArray();
  localObject1 = new byte[16];
  System.arraycopy((byte[])f, 0, localObject1, 0, ((byte[])f).length);
  System.arraycopy(this.e.getBytes(), 0, localObject1, 10, this.e.getBytes().length);
  phoneHome((byte[])localObject2, (byte[])localObject1);
  localObject1 = str;
  if (new String((byte[])localObject2).startsWith(c)) {
    localObject1 = new String((byte[])localObject2);
  }
}
```

`Snackbar` line makes a toast pop-up with the value of `localObject1`, which is
`flag` by default, which is `"Sorry no rootkit for you :("`. When the value of
`localObject2` after the `phoneHome(localObject2, localObject1)` starts with the
value of `c`, which is `"Congratula"`, the `localObject1` changes. So our goal
is to find the value of `e` that leads `localObject1` to change.

The value of `localObject2` is the content of the asset with its path `g`, which
is `assets/a/d/c/c`. The first 10 bytes of `localObject1` are the same with `f`,
and the last 6 bytes are the value of `e`. So we need to know the value of `e`,
which will be at most six digits of number.

### Emulating `phoneHome`

We can obtain a decompiled code of `phoneHome`, and this is the exploit.

``` c
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define _BYTE unsigned char
#define BYTEn(x, n) (*((_BYTE *) &(x) + n))
#define BYTE1(x) BYTEn(x, 1)
#define BYTE2(x) BYTEn(x, 2)
#define BYTE3(x) BYTEn(x, 3)

void check(char *input) {
    char g[11] = "Congratula";
    char a_d_c_c[113] = "\xFE\xA0\xAD\x80 Y\xAB\x12\xD7\xC3\x9C\x88\xFA,\x1D\xFC\x81""F\r\xDC\xE9\xCE\xCCWx\xF5""A_R\x02""6\xD5""3\x18""f:@&\xE8n\xB6\xCDr\xB7<\x01""f\xB1O\x99#c\x95w4ai\xF6\xA9S@7ACO\x98\x95,z'<\x98h\x1A\x88\xA8\xB7\x85\xBB\x15O\x1A\x01M\xC9\xC8\x9BuxW\x7F\x98\r\xD8Q\xA8\"\xB9^YMqO\x1A\x81\xA9\xBF\a)\xED\xFD\x83";
    int v4, v5, v6, v7, v8, v9, v10, v12, v13, v14, v15, v17, v18;
    unsigned int v16;

    v17 = a_d_c_c;
    v18 = input;
    v4 = v18;
    v5 = 112;
    v12 = (*(_BYTE *) (v4 + 2) << 16) | (*(_BYTE *) (v4 + 3) << 24) | *(_BYTE *) v4 | (uint16_t) (*(_BYTE *) (v4 + 1) << 8);
    v13 = (*(_BYTE *) (v4 + 6) << 16) | (*(_BYTE *) (v4 + 7) << 24) | *(_BYTE *) (v4 + 4) | (uint16_t) (*(_BYTE *) (v4 + 5) << 8);
    v14 = (*(_BYTE *) (v4 + 10) << 16) | (*(_BYTE *) (v4 + 11) << 24) | *(_BYTE *) (v4 + 8) | (uint16_t) (*(_BYTE *) (v4 + 9) << 8);
    v6 = (*(_BYTE *) (v4 + 15) << 24) | *(_BYTE *) (v4 + 12) | (uint16_t) (*(_BYTE *) (v4 + 13) << 8) | (*(_BYTE *) (v4 + 14) << 16);
    if (v5 > 0) {
        v15 = v17 + 1;
        v16 = v17 + ((v5 - 1) & 0xFFFFFFF8) + 9;
        do {
            v7 = (uint16_t) (*(_BYTE *) v15 << 8) | (*(_BYTE *) (v15 + 2) << 24) | *(_BYTE *) (v15 - 1) | (*(_BYTE *) (v15 + 1) << 16);
            v8 = 0xD5B7DDE0;
            v9 = (uint16_t) (*(_BYTE *) (v15 + 4) << 8) | *(_BYTE *) (v15 + 3) | (*(_BYTE *) (v15 + 6) << 24) | (*(_BYTE *) (v15 + 5) << 16);
            do {
                v9 -= (v7 + v8) ^ (16 * v7 + v14) ^ (v6 + ((unsigned int) v7 >> 5));
                v7 -= (v9 + v8) ^ (16 * v9 + v12) ^ (v13 + ((unsigned int) v9 >> 5));
                v8 += 0x21524111;
            } while (v8);
            *(_BYTE *) (v15 - 1) = v7;
            v10 = v15 + 8;
            *(_BYTE *) (v10 - 8) = BYTE1(v7);
            *(_BYTE *) (v10 - 7) = BYTE2(v7);
            *(_BYTE *) (v10 - 6) = BYTE3(v7);
            *(_BYTE *) (v10 - 5) = v9;
            *(_BYTE *) (v10 - 4) = BYTE1(v9);
            *(_BYTE *) (v10 - 3) = BYTE2(v9);
            *(_BYTE *) (v10 - 2) = BYTE3(v9);
            v15 += 8;
        } while (v10 != v16);
    }
    if (strncmp(v17, g, strlen(g)) == 0) {
        printf("Found: e: '%s'\n", input + 10);
        printf("%s\n", v17);
        exit(0);
    }
}

void replace_zero(char *f) {
    int i = 10;
    while (f[i] != '\0') {
        if (f[i] == '0') {
            f[i] = ' ';
        }
        i++;
    }
}

int main() {
    char f[17] = "!\x00\x86\xB7\xFF\x86]\x06-0";
    int e;
    int len;
    int i;

    for (e = 0; e < 1000000; e++) {
        for (i = 10; i < 17; i++) {
            f[i] = 0;
        }
        if (e < 10) {
            sprintf(f + 10, "%d", e);
            replace_zero(f);
            check(f);
        }
        if (e < 100) {
            sprintf(f + 10, "%02d", e);
            replace_zero(f);
            check(f);
        }
        if (e < 1000) {
            sprintf(f + 10, "%03d", e);
            replace_zero(f);
            check(f);
        }
        if (e < 10000) {
            sprintf(f + 10, "%04d", e);
            replace_zero(f);
            check(f);
        }
        if (e < 100000) {
            sprintf(f + 10, "%05d", e);
            replace_zero(f);
            check(f);
        }
        sprintf(f + 10, "%06d", e);
        replace_zero(f);
        check(f);
    }

    return 0;
}
```

Executing it is simple:

``` sh
gcc libdroid.c -m32 -o libdroid
./libdroid
Found: e: '1 3875'
Congratulations! The rootkit is sucessfully installed. The Flag is 32C3_this_is_build_for_flag_ship_phones
```

So the flag is `32C3_this_is_build_for_flag_ship_phones`. If you want to see the
flag within the application, just press `103875` on it.

![libdroid Flag](/images/2015/12/30/libdroid_flag.min.jpg)
