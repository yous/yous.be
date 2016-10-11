---
layout: post
title: "HITCON CTF 2016: ROP write-up"
date: 2016-10-11 08:25:35 +0000
comments: false
categories:
    - CTF
description: "Write-up of HITCON CTF 2016: ROP."
keywords: hitcon, hitcon ctf 2016, ruby, rubyvm, instructionsequence, reversing, write-up
redirect_from: /p/20161011/
---

## ROP (Reverse 250)

> **Description**
>
> Who doesn't like ROP?<br>
> Let's try some new features introduced in 2.3.
>
> [rop.iseq](https://s3-ap-northeast-1.amazonaws.com/hitcon2016qual/rop.iseq_a9ac4b7a1669257d0914ca556a6aa6d14b4a2092)
>
> **Hint**
>
> None

If the above link doesn't work, please use this
[link](/downloads/2016/10/11/rop.iseq_a9ac4b7a1669257d0914ca556a6aa6d14b4a2092).

## New features?

Well, see
[the Ruby 2.3.0 news](https://www.ruby-lang.org/en/news/2015/12/25/ruby-2-3-0-released/).

> [RubyVM::InstructionSequence#to_binary and .load_from_binary](https://bugs.ruby-lang.org/issues/11788)
> are introduced as experimental features. With these features, we can make a
> ISeq (bytecode) pre-compilation system.

Yes, so this is about using `RubyVM::InstructionSequence.load_from_binary`.
Let's just start with:

``` ruby
RubyVM::InstructionSequence.load_from_binary(File.read('rop.iseq'))
```

But you can face this kind of error:

```
RuntimeError: unmatched platform
        from (irb):1:in `load_from_binary'
        from (irb):1
        from /usr/bin/irb:11:in `<main>'
```

By checking `strings rop.iseq`, we can find `x86_64-linux`. So we need Ruby 2.3
on Linux x86_64 platform. You can see the platform by `ruby --version`. This is
the version of my one:

```
ruby 2.3.1p112 (2016-04-26 revision 54768) [x86_64-linux]
```

<!-- more -->

## Disassembling

Once the binary is loaded by `.load_from_binary`, we can get the instruction
sequence as a String by
[`#disasm`](http://ruby-doc.org/core-2.3.0/RubyVM/InstructionSequence.html#method-i-disasm):

``` ruby
puts RubyVM::InstructionSequence.load_from_binary(File.read('rop.iseq')).disasm
```

Then you get a readable instruction sequence!

```
== disasm: #<ISeq:<compiled>@<compiled>>================================
== catch table
| catch type: break  st: 0096 ed: 0102 sp: 0000 cont: 0102
| catch type: break  st: 0239 ed: 0245 sp: 0000 cont: 0245
|------------------------------------------------------------------------
local table (size: 3, argc: 0 [opts: 0, rest: -1, post: 0, block: -1, kw: -1@-1, kwrest: -1])
[ 3] k          [ 2] xs
0000 trace            1                                               (   1)
0002 putself
0003 putstring        "digest"
0005 opt_send_without_block <callinfo!mid:require, argc:1, FCALL|ARGS_SIMPLE>, <callcache>
0008 pop
0009 trace            1                                               (   2)
0011 putself
0012 putstring        "prime"
0014 opt_send_without_block <callinfo!mid:require, argc:1, FCALL|ARGS_SIMPLE>, <callcache>
0017 pop
0018 trace            1                                               (   4)
0020 putspecialobject 3
0022 putnil
0023 defineclass      :String, <class:String>, 0
0027 pop
0028 trace            1                                               (  22)
0030 putspecialobject 1
0032 putobject        :gg
0034 putiseq          gg
0036 opt_send_without_block <callinfo!mid:core#define_method, argc:2, ARGS_SIMPLE>, <callcache>
0039 pop
0040 trace            1                                               (  27)
0042 putspecialobject 1
0044 putobject        :f
0046 putiseq          f
0048 opt_send_without_block <callinfo!mid:core#define_method, argc:2, ARGS_SIMPLE>, <callcache>
0051 pop
0052 trace            1                                               (  38)
0054 getglobal        $stdin
0056 opt_send_without_block <callinfo!mid:gets, argc:0, ARGS_SIMPLE>, <callcache>
0059 opt_send_without_block <callinfo!mid:chomp, argc:0, ARGS_SIMPLE>, <callcache>
0062 setlocal_OP__WC__0 3
0064 trace            1                                               (  39)
0066 getlocal_OP__WC__0 3
0068 putstring        "-"
0070 opt_send_without_block <callinfo!mid:split, argc:1, ARGS_SIMPLE>, <callcache>
0073 setlocal_OP__WC__0 2
0075 trace            1                                               (  40)
0077 getlocal_OP__WC__0 2
0079 opt_size         <callinfo!mid:size, argc:0, ARGS_SIMPLE>, <callcache>
0082 putobject        5
0084 opt_eq           <callinfo!mid:==, argc:1, ARGS_SIMPLE>, <callcache>
0087 branchif         94
0089 putself
0090 opt_send_without_block <callinfo!mid:gg, argc:0, FCALL|VCALL|ARGS_SIMPLE>, <callcache>
0093 pop
0094 trace            1                                               (  41)
0096 getlocal_OP__WC__0 2
0098 send             <callinfo!mid:all?, argc:0>, <callcache>, block in <compiled>
0102 branchif         109
0104 putself
0105 opt_send_without_block <callinfo!mid:gg, argc:0, FCALL|VCALL|ARGS_SIMPLE>, <callcache>
0108 pop
0109 trace            1                                               (  42)
0111 getlocal_OP__WC__0 2
0113 putobject_OP_INT2FIX_O_0_C_
0114 opt_aref         <callinfo!mid:[], argc:1, ARGS_SIMPLE>, <callcache>
0117 putobject        16
0119 opt_send_without_block <callinfo!mid:to_i, argc:1, ARGS_SIMPLE>, <callcache>
0122 putobject        31337
0124 opt_eq           <callinfo!mid:==, argc:1, ARGS_SIMPLE>, <callcache>
0127 branchif         134
0129 putself
0130 opt_send_without_block <callinfo!mid:gg, argc:0, FCALL|VCALL|ARGS_SIMPLE>, <callcache>
0133 pop
0134 trace            1                                               (  43)
0136 getlocal_OP__WC__0 2
0138 putobject_OP_INT2FIX_O_1_C_
0139 opt_aref         <callinfo!mid:[], argc:1, ARGS_SIMPLE>, <callcache>
0142 opt_send_without_block <callinfo!mid:reverse, argc:0, ARGS_SIMPLE>, <callcache>
0145 putstring        "FACE"
0147 opt_eq           <callinfo!mid:==, argc:1, ARGS_SIMPLE>, <callcache>
0150 branchif         157
0152 putself
0153 opt_send_without_block <callinfo!mid:gg, argc:0, FCALL|VCALL|ARGS_SIMPLE>, <callcache>
0156 pop
0157 trace            1                                               (  44)
0159 putself
0160 putobject        217
0162 getlocal_OP__WC__0 2
0164 putobject        2
0166 opt_aref         <callinfo!mid:[], argc:1, ARGS_SIMPLE>, <callcache>
0169 putobject        16
0171 opt_send_without_block <callinfo!mid:to_i, argc:1, ARGS_SIMPLE>, <callcache>
0174 putobject        314159
0176 opt_send_without_block <callinfo!mid:f, argc:3, FCALL|ARGS_SIMPLE>, <callcache>
0179 putobject        28
0181 opt_send_without_block <callinfo!mid:to_s, argc:1, ARGS_SIMPLE>, <callcache>
0184 opt_send_without_block <callinfo!mid:upcase, argc:0, ARGS_SIMPLE>, <callcache>
0187 putstring        "48D5"
0189 opt_eq           <callinfo!mid:==, argc:1, ARGS_SIMPLE>, <callcache>
0192 branchif         199
0194 putself
0195 opt_send_without_block <callinfo!mid:gg, argc:0, FCALL|VCALL|ARGS_SIMPLE>, <callcache>
0198 pop
0199 trace            1                                               (  45)
0201 getlocal_OP__WC__0 2
0203 putobject        3
0205 opt_aref         <callinfo!mid:[], argc:1, ARGS_SIMPLE>, <callcache>
0208 putobject        10
0210 opt_send_without_block <callinfo!mid:to_i, argc:1, ARGS_SIMPLE>, <callcache>
0213 opt_send_without_block <callinfo!mid:prime_division, argc:0, ARGS_SIMPLE>, <callcache>
0216 putobject        :first
0218 send             <callinfo!mid:map, argc:0, ARGS_BLOCKARG>, <callcache>, nil
0222 opt_send_without_block <callinfo!mid:sort, argc:0, ARGS_SIMPLE>, <callcache>
0225 duparray         [53, 97]
0227 opt_eq           <callinfo!mid:==, argc:1, ARGS_SIMPLE>, <callcache>
0230 branchif         237
0232 putself
0233 opt_send_without_block <callinfo!mid:gg, argc:0, FCALL|VCALL|ARGS_SIMPLE>, <callcache>
0236 pop
0237 trace            1                                               (  46)
0239 getlocal_OP__WC__0 2
0241 send             <callinfo!mid:map, argc:0>, <callcache>, block in <compiled>
0245 putobject        :^
0247 opt_send_without_block <callinfo!mid:inject, argc:1, ARGS_SIMPLE>, <callcache>
0250 opt_send_without_block <callinfo!mid:to_s, argc:0, ARGS_SIMPLE>, <callcache>
0253 opt_send_without_block <callinfo!mid:sha1, argc:0, ARGS_SIMPLE>, <callcache>
0256 putstring        "947d46f8060d9d7025cc5807ab9bf1b3b9143304"
0258 opt_eq           <callinfo!mid:==, argc:1, ARGS_SIMPLE>, <callcache>
0261 branchif         268
0263 putself
0264 opt_send_without_block <callinfo!mid:gg, argc:0, FCALL|VCALL|ARGS_SIMPLE>, <callcache>
0267 pop
0268 trace            1                                               (  48)
0270 putself
0271 putobject        "Congratz! flag is "
0273 putstring        "bce410e85433ba94f0d832d99556f9764b220eeda7e807fe4938a5e6effa7d83c765e1795b6c26af8ad258f6"
0275 opt_send_without_block <callinfo!mid:dehex, argc:0, ARGS_SIMPLE>, <callcache>
0278 getlocal_OP__WC__0 3
0280 opt_send_without_block <callinfo!mid:sha1, argc:0, ARGS_SIMPLE>, <callcache>
0283 opt_send_without_block <callinfo!mid:dehex, argc:0, ARGS_SIMPLE>, <callcache>
0286 opt_send_without_block <callinfo!mid:^, argc:1, ARGS_SIMPLE>, <callcache>
0289 tostring
0290 concatstrings    2
0292 opt_send_without_block <callinfo!mid:puts, argc:1, FCALL|ARGS_SIMPLE>, <callcache>
0295 leave
== disasm: #<ISeq:<class:String>@<compiled>>============================
0000 trace            2                                               (   4)
0002 trace            1                                               (   5)
0004 putspecialobject 1
0006 putobject        :^
0008 putiseq          ^
0010 opt_send_without_block <callinfo!mid:core#define_method, argc:2, ARGS_SIMPLE>, <callcache>
0013 pop
0014 trace            1                                               (   9)
0016 putspecialobject 1
0018 putobject        :sha1
0020 putiseq          sha1
0022 opt_send_without_block <callinfo!mid:core#define_method, argc:2, ARGS_SIMPLE>, <callcache>
0025 pop
0026 trace            1                                               (  13)
0028 putspecialobject 1
0030 putobject        :enhex
0032 putiseq          enhex
0034 opt_send_without_block <callinfo!mid:core#define_method, argc:2, ARGS_SIMPLE>, <callcache>
0037 pop
0038 trace            1                                               (  17)
0040 putspecialobject 1
0042 putobject        :dehex
0044 putiseq          dehex
0046 opt_send_without_block <callinfo!mid:core#define_method, argc:2, ARGS_SIMPLE>, <callcache>
0049 trace            4                                               (  20)
0051 leave                                                            (  17)
== disasm: #<ISeq:^@<compiled>>=========================================
== catch table
| catch type: break  st: 0004 ed: 0015 sp: 0000 cont: 0015
|------------------------------------------------------------------------
local table (size: 2, argc: 1 [opts: 0, rest: -1, post: 0, block: -1, kw: -1@-1, kwrest: -1])
[ 2] other<Arg>
0000 trace            8                                               (   5)
0002 trace            1                                               (   6)
0004 putself
0005 opt_send_without_block <callinfo!mid:bytes, argc:0, ARGS_SIMPLE>, <callcache>
0008 opt_send_without_block <callinfo!mid:map, argc:0, ARGS_SIMPLE>, <callcache>
0011 send             <callinfo!mid:with_index, argc:0>, <callcache>, block in ^
0015 putstring        "C*"
0017 opt_send_without_block <callinfo!mid:pack, argc:1, ARGS_SIMPLE>, <callcache>
0020 trace            16                                              (   7)
0022 leave                                                            (   6)
== disasm: #<ISeq:block in ^@<compiled>>================================
== catch table
| catch type: redo   st: 0002 ed: 0027 sp: 0000 cont: 0002
| catch type: next   st: 0002 ed: 0027 sp: 0000 cont: 0027
|------------------------------------------------------------------------
local table (size: 3, argc: 2 [opts: 0, rest: -1, post: 0, block: -1, kw: -1@-1, kwrest: -1])
[ 3] x<Arg>     [ 2] i<Arg>
0000 trace            256                                             (   6)
0002 trace            1
0004 getlocal_OP__WC__0 3
0006 getlocal_OP__WC__1 2
0008 getlocal_OP__WC__0 2
0010 getlocal_OP__WC__1 2
0012 opt_size         <callinfo!mid:size, argc:0, ARGS_SIMPLE>, <callcache>
0015 opt_mod          <callinfo!mid:%, argc:1, ARGS_SIMPLE>, <callcache>
0018 opt_aref         <callinfo!mid:[], argc:1, ARGS_SIMPLE>, <callcache>
0021 opt_send_without_block <callinfo!mid:ord, argc:0, ARGS_SIMPLE>, <callcache>
0024 opt_send_without_block <callinfo!mid:^, argc:1, ARGS_SIMPLE>, <callcache>
0027 trace            512
0029 leave
== disasm: #<ISeq:sha1@<compiled>>======================================
0000 trace            8                                               (   9)
0002 trace            1                                               (  10)
0004 getinlinecache   13, <is:0>
0007 getconstant      :Digest
0009 getconstant      :SHA1
0011 setinlinecache   <is:0>
0013 putself
0014 opt_send_without_block <callinfo!mid:hexdigest, argc:1, ARGS_SIMPLE>, <callcache>
0017 trace            16                                              (  11)
0019 leave                                                            (  10)
== disasm: #<ISeq:enhex@<compiled>>=====================================
0000 trace            8                                               (  13)
0002 trace            1                                               (  14)
0004 putself
0005 putstring        "H*"
0007 opt_send_without_block <callinfo!mid:unpack, argc:1, ARGS_SIMPLE>, <callcache>
0010 putobject_OP_INT2FIX_O_0_C_
0011 opt_aref         <callinfo!mid:[], argc:1, ARGS_SIMPLE>, <callcache>
0014 trace            16                                              (  15)
0016 leave                                                            (  14)
== disasm: #<ISeq:dehex@<compiled>>=====================================
0000 trace            8                                               (  17)
0002 trace            1                                               (  18)
0004 putself
0005 newarray         1
0007 putstring        "H*"
0009 opt_send_without_block <callinfo!mid:pack, argc:1, ARGS_SIMPLE>, <callcache>
0012 trace            16                                              (  19)
0014 leave                                                            (  18)
== disasm: #<ISeq:gg@<compiled>>========================================
0000 trace            8                                               (  22)
0002 trace            1                                               (  23)
0004 putself
0005 putstring        "Invalid Key @_@"
0007 opt_send_without_block <callinfo!mid:puts, argc:1, FCALL|ARGS_SIMPLE>, <callcache>
0010 pop
0011 trace            1                                               (  24)
0013 putself
0014 putobject_OP_INT2FIX_O_1_C_
0015 opt_send_without_block <callinfo!mid:exit, argc:1, FCALL|ARGS_SIMPLE>, <callcache>
0018 trace            16                                              (  25)
0020 leave                                                            (  24)
== disasm: #<ISeq:f@<compiled>>=========================================
== catch table
| catch type: break  st: 0021 ed: 0086 sp: 0000 cont: 0086
| catch type: next   st: 0021 ed: 0086 sp: 0000 cont: 0018
| catch type: redo   st: 0021 ed: 0086 sp: 0000 cont: 0021
|------------------------------------------------------------------------
local table (size: 6, argc: 3 [opts: 0, rest: -1, post: 0, block: -1, kw: -1@-1, kwrest: -1])
[ 6] a<Arg>     [ 5] b<Arg>     [ 4] m<Arg>     [ 3] s          [ 2] r
0000 trace            8                                               (  27)
0002 trace            1                                               (  28)
0004 putobject_OP_INT2FIX_O_1_C_
0005 setlocal_OP__WC__0 3
0007 trace            1                                               (  29)
0009 getlocal_OP__WC__0 6
0011 setlocal_OP__WC__0 2
0013 trace            1                                               (  30)
0015 jump             75
0017 putnil
0018 pop
0019 jump             75
0021 trace            1                                               (  31)
0023 getlocal_OP__WC__0 5
0025 putobject_OP_INT2FIX_O_0_C_
0026 opt_aref         <callinfo!mid:[], argc:1, ARGS_SIMPLE>, <callcache>
0029 putobject_OP_INT2FIX_O_1_C_
0030 opt_eq           <callinfo!mid:==, argc:1, ARGS_SIMPLE>, <callcache>
0033 branchunless     49
0035 getlocal_OP__WC__0 3
0037 getlocal_OP__WC__0 2
0039 opt_mult         <callinfo!mid:*, argc:1, ARGS_SIMPLE>, <callcache>
0042 getlocal_OP__WC__0 4
0044 opt_mod          <callinfo!mid:%, argc:1, ARGS_SIMPLE>, <callcache>
0047 setlocal_OP__WC__0 3
0049 trace            1                                               (  32)
0051 getlocal_OP__WC__0 5
0053 putobject_OP_INT2FIX_O_1_C_
0054 opt_send_without_block <callinfo!mid:>>, argc:1, ARGS_SIMPLE>, <callcache>
0057 setlocal_OP__WC__0 5
0059 trace            1                                               (  33)
0061 getlocal_OP__WC__0 2
0063 getlocal_OP__WC__0 2
0065 opt_mult         <callinfo!mid:*, argc:1, ARGS_SIMPLE>, <callcache>
0068 getlocal_OP__WC__0 4
0070 opt_mod          <callinfo!mid:%, argc:1, ARGS_SIMPLE>, <callcache>
0073 setlocal_OP__WC__0 2
0075 getlocal_OP__WC__0 5                                             (  30)
0077 putobject_OP_INT2FIX_O_0_C_
0078 opt_neq          <callinfo!mid:!=, argc:1, ARGS_SIMPLE>, <callcache>, <callinfo!mid:==, argc:1, ARGS_SIMPLE>, <callcache>
0083 branchif         21
0085 putnil
0086 pop
0087 trace            1                                               (  35)
0089 getlocal_OP__WC__0 3
0091 trace            16                                              (  36)
0093 leave                                                            (  35)
== disasm: #<ISeq:block in <compiled>@<compiled>>=======================
== catch table
| catch type: redo   st: 0002 ed: 0011 sp: 0000 cont: 0002
| catch type: next   st: 0002 ed: 0011 sp: 0000 cont: 0011
|------------------------------------------------------------------------
local table (size: 2, argc: 1 [opts: 0, rest: -1, post: 0, block: -1, kw: -1@-1, kwrest: -1])
[ 2] x<Arg>
0000 trace            256                                             (  41)
0002 trace            1
0004 getlocal_OP__WC__0 2
0006 putobject        /^[0-9A-F]{4}$/
0008 opt_regexpmatch2 <callinfo!mid:=~, argc:1, ARGS_SIMPLE>, <callcache>
0011 trace            512
0013 leave
== disasm: #<ISeq:block in <compiled>@<compiled>>=======================
== catch table
| catch type: redo   st: 0002 ed: 0011 sp: 0000 cont: 0002
| catch type: next   st: 0002 ed: 0011 sp: 0000 cont: 0011
|------------------------------------------------------------------------
local table (size: 2, argc: 1 [opts: 0, rest: -1, post: 0, block: -1, kw: -1@-1, kwrest: -1])
[ 2] x<Arg>
0000 trace            256                                             (  46)
0002 trace            1
0004 getlocal_OP__WC__0 2
0006 putobject        16
0008 opt_send_without_block <callinfo!mid:to_i, argc:1, ARGS_SIMPLE>, <callcache>
0011 trace            512
0013 leave
```

Quite long, but this is the summary:

``` ruby
class String
  def ^; end

  def sha1; end

  def enhex; end

  def dehex; end
end

def gg; end

def f; end

# main code
```

Note that the last two blocks are block code for `#all?` and `#map`.

## Rebuilding the code

We got the instruction sequence, and we can also compile our own code with the
following script:

``` ruby
puts RubyVM::InstructionSequence.compile_file('code.rb').disasm
```

For example, create `code.rb` with:

``` ruby
require 'digest'
require 'prime'
```

Then the result of script is:

```
== disasm: #<ISeq:<main>@code.rb>=======================================
0000 trace            1                                               (   1)
0002 putself
0003 putstring        "digest"
0005 opt_send_without_block <callinfo!mid:require, argc:1, FCALL|ARGS_SIMPLE>, <callcache>
0008 pop
0009 trace            1                                               (   2)
0011 putself
0012 putstring        "prime"
0014 opt_send_without_block <callinfo!mid:require, argc:1, FCALL|ARGS_SIMPLE>, <callcache>
0017 leave
```

Let me just skip the details of recovering, so here is the original code.

``` ruby
require 'digest'
require 'prime'

class String
  def ^(other)
    self.bytes.map.with_index { |x, i| x ^ other[i % other.size].ord }.pack('C*')
  end

  def sha1
    Digest::SHA1.hexdigest(self)
  end

  def enhex
    self.unpack('H*')[0]
  end

  def dehex
    [self].pack('H*')
  end
end

def gg
  puts 'Invalid Key @_@'
  exit(1)
end

def f(a, b, m)
  s = 1
  r = a
  while b != 0
    s = (s * r) % m if b[0] == 1
    b = b >> 1
    r = (r * r) % m
  end
  s
end

k = $stdin.gets.chomp
xs = k.split('-')

gg unless xs.size == 5
gg unless xs.all? { |x| x =~ /^[0-9A-F]{4}$/ }
gg unless xs[0].to_i(16) == 31337
gg unless xs[1].reverse == 'FACE'
gg unless f(217, xs[2].to_i(16), 314159).to_s(28).upcase == '48D5'
gg unless xs[3].to_i(10).prime_division.map(&:first).sort == [53, 97]
gg unless xs.map { |x| x.to_i(16) }.inject(:^).to_s.sha1 == '947d46f8060d9d7025cc5807ab9bf1b3b9143304'

puts "Congratz! flag is #{'bce410e85433ba94f0d832d99556f9764b220eeda7e807fe4938a5e6effa7d83c765e1795b6c26af8ad258f6'.dehex ^ k.sha1.dehex}"
```

## Finding the answer input

See the core part again:

``` ruby
gg unless xs.size == 5
gg unless xs.all? { |x| x =~ /^[0-9A-F]{4}$/ }
gg unless xs[0].to_i(16) == 31337
gg unless xs[1].reverse == 'FACE'
gg unless f(217, xs[2].to_i(16), 314159).to_s(28).upcase == '48D5'
gg unless xs[3].to_i(10).prime_division.map(&:first).sort == [53, 97]
gg unless xs.map { |x| x.to_i(16) }.inject(:^).to_s.sha1 == '947d46f8060d9d7025cc5807ab9bf1b3b9143304'
```

By the first two lines, we have to enter `XXXX-XXXX-XXXX-XXXX-XXXX` format.
- 31337 is 0x7A69, so the first word is `7A69`.
- The second one is obviously `ECAF`.
- For the third word, we can just do a brute force attack.

  ``` ruby
  (0...0xffff).each do |x|
    if f(217, x, 314159).to_s(28).upcase == '48D5'
      puts x.to_s(16).upcase
      break
    end
  end
  ```

  This returns `1BD2`.
- 53 * 97 = 5141, so the fourth is `5141`.
- The SHA1 in the last condition is the same with `'5671'.sha1`. So we can get
  the last word by computing XORs of all previous words and 5671.

  ``` irb
  >> (0x7A69 ^ 0xECAF ^ 0x1BD2 ^ 0x5141 ^ 5671).to_s(16).upcase
  => "CA72"
  ```

So the answer input is `7A69-ECAF-1BD2-5141-CA72`.

``` sh
$ ruby code.rb
7A69-ECAF-1BD2-5141-CA72
Congratz! flag is hitcon{ROP = Ruby Obsecured Programming ^_<}
```

So the flag is `hitcon{ROP = Ruby Obsecured Programming ^_<}`.
