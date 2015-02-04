---
layout: post
title: "Octopress에서 Facebook Open Graph와 Twitter Cards 지원하기"
date: 2014-02-24 21:50:36 +0900
comments: false
categories:
    - Octopress
keywords: octopress, facebook, open graph, twitter, twitter card
redirect_from: /p/20140224/
facebook:
    image: http://yous.be/images/2014/02/24/facebook_open_graph.png
twitter_card:
    image: http://yous.be/images/2014/02/24/twitter_card_summary.png
---

블로그에 글을 쓰고 나면 트위터나 페이스북에 링크를 공유하곤 하는데 페이스북의 미리보기가 적절히 표시되지 않고 있다는 사실을 깨달았다. 또한 트위터도 그와 비슷한 기능을 제공하는데, 둘 다 지원하면 좋겠다는 생각을 했다. 이를 제대로 지원하려면 [Facebook Open Graph tags][]와 [Twitter Cards][]에 대해 알아야 한다. 웹 페이지에 적절한 [메타 태그][Meta element]를 추가해 주면 페이스북과 트위터에서 인식하고 올바른, 작성자가 의도한 미리보기를 보여준다. 기본적으로 Zac Clancy가 쓴 [Octopress에서 이 두 가지를 지원하는 글][Black Glasses]에 상세히 설명되어 있다.

[Facebook Open Graph tags]: https://developers.facebook.com/docs/opengraph/howtos/maximizing-distribution-media-content#tags
[Twitter Cards]: https://dev.twitter.com/docs/cards
[Meta element]: http://en.wikipedia.org/wiki/Meta_element
[Black Glasses]: http://blackglasses.me/2013/09/19/twitter-cards-facebook-open-graph-and-octopress/

<!-- more -->

## <a id="facebook-open-graph-tags"></a>Facebook Open Graph Tags

![Facebook Open Graph](/images/2014/02/24/facebook_open_graph.png "Facebook Open Graph")

페이스북에 웹 페이지가 제대로 인식되게 하려면 [Open Graph 태그][Facebook Open Graph tags]를 이용해야 한다. 기본적으로 채워야 할 태그들은 다음과 같다:

- `og:title`: 사이트 이름 등의 브랜드를 제외한 글 제목이다.
- `og:site_name`: 웹 사이트의 이름이다. URL이 아니라 이름이다. (예: "imdb.com"이 아닌 "IMDb")
- `og:url`: 글의 고유 식별자가 된다. 검색 엔진 최적화를 위해 사용된 [표준(canonical) URL][Canonical link element]과 연결되어야 하며, 어떤 세션 변수나 사용자 식별 인자나 카운터를 포함하지 않아야 한다. 만약 이 부분을 잘못 사용하게 되면, '좋아요'와 '공유'의 수가 이 URL로 합해지지 않고 이 URL의 모든 변형으로 흩어질 것이다.
- `og:description`: 내용 일부를 상세히 설명한 글로, 보통 2~4문장이다. 이 태그는 선택 가능하지만 사람들이 읽고 공유하는 비율을 높일 수 있다.
- `og:image`: 연관된 이미지다. 최소 1200x630 픽셀 크기의 이미지 사용을 추천한다.
- `fb:app_id`: 페이스북이 사이트의 신원을 파악할 수 있게 해 주는 고유 ID다. Facebook Insights가 제대로 동작하는 데에 중요하다. 자세한 내용은 [Insights 문서][Insights documentation]에서 확인할 수 있다.

[Canonical link element]: http://en.wikipedia.org/wiki/Canonical_link_element
[Insights documentation]: https://developers.facebook.com/docs/insights/

다른 종류의 태그를 더 추가할 수도 있다:

- `og:type`: 페이스북의 뉴스피드는 당신의 글을 미디어 종류에 따라 다르게 보여준다.[일반적으로 쓰이는 오브젝트 타입][number of different common object types]은 이미 정의되어 있다. 만약 오브젝트 타입을 설정하지 않으면 기본 타입으로 `website`가 쓰인다. Open Graph를 통해 당신만의 타입을 정할 수도 있다.
- `og:locale`: 리소스의 언어다. 기본 설정은 `en_US`다. `og:locale:alternate`를 통해 다른 언어도 가능하다는 것을 나타낼 수 있다. 예제와 추가 정보는 [국제화][Internationalization]와 [Open Graph 국제화][Open Graph Internationalization] 페이지를 보라.
- `article:author`: [글의 저자들로 통하는 링크][property links to the authors of the article]다. 링크 주소는 뉴스피드에 나타났을 때 저자를 팔로우 할 수 있는 페이스북 프로필이나 페이스북 페이지가 될 수 있다. (저자들은 사람들이 팔로우 할 수 있게 [팔로우][follow] 기능을 켜 두어야 한다.)
- `article:publisher`: [글의 발행인으로 통하는 링크][property links to the publisher of the article]다. 링크 주소는 페이스북 페이지여야 한다. 페이스북은 발행인이 뉴스피드에 표시되었을 때 그것을 '좋아요' 하는 기능을 제공할 수 있다. 이 태그는 미디어 발행인만 쓸 수 있다.

[number of different common object types]: http://ogp.me/#types
[Internationalization]: https://developers.facebook.com/docs/internationalization/
[Open Graph Internationalization]: https://developers.facebook.com/docs/technical-guides/opengraph/internationalization/
[property links to the authors of the article]: https://developers.facebook.com/docs/reference/opengraph/object-type/article
[follow]: https://developers.facebook.com/docs/opengraph/howtos/maximizing-distribution-media-content#follow
[property links to the publisher of the article]: https://developers.facebook.com/docs/reference/opengraph/object-type/article

## <a id="twitter-cards"></a>Twitter Cards

[Twitter Cards][]는 트윗 자체에 링크의 내용을 보여주는 '카드'를 추가하는 기능이다.

![Twitter Summary Card](/images/2014/02/24/twitter_card_summary.png "Twitter Summary Card")

카드의 종류는 7개가 있으며 원하는 용도에 따라 적절히 사용할 수 있다.

- [Summary Card][]: 기본 카드. 제목, 설명, 섬네일, 트위터 계정을 포함하고 있다.
- [Summary Card with Large Image][]: Summary Card와 비슷하지만 이미지를 강조할 수 있다.
- [Photo Card][]: 트윗 형태의 사진 카드.
- [Gallery Card][]: 여러 사진을 강조하기 위한 카드다.
- [App Card][]: 애플리케이션 정보를 제공하기 위한 카드다.
- [Player Card][]: 트윗 형태의 비디오/오디오/미디어 재생 카드다.
- [Product Card][]: 상품 내용을 더 잘 나타내기 위한 트윗 카드다.

[Summary Card]: https://dev.twitter.com/docs/cards/types/summary-card
[Summary Card with Large Image]: https://dev.twitter.com/docs/cards/large-image-summary-card
[Photo Card]: https://dev.twitter.com/docs/cards/types/photo-card
[Gallery Card]: https://dev.twitter.com/docs/cards/types/gallery-card
[App Card]: https://dev.twitter.com/docs/cards/types/app-card
[Player Card]: https://dev.twitter.com/docs/cards/types/player-card
[Product Card]: https://dev.twitter.com/docs/cards/types/product-card

트위터는 [카드 검사 도구][Card Validator]를 직접 제공하고 있으므로 각 종류의 카드가 어떻게 보이는지, 자신의 사이트가 제대로 인식되는지 테스트 해볼 수 있다.

[Card Validator]: https://cards-dev.twitter.com/validator

## <a id="support-in-octopress"></a>Octopress에서 지원하기

페이스북 Open Graph를 위한 설정 값을 `_config.yml`에 추가한다.

``` yaml
...
# Facebook Insights / Open Graph
facebook_app_id:
facebook_page:
```

페이스북 App ID는 [페이스북 인사이트][Facebook Insights]에서 '웹사이트를 위한 인사이트' 버튼을 눌러 얻을 수 있다. 페이스북 페이지 주소는 `article:author`에 사용될 정보지만 입력하지 않아도 된다. 트위터는 `_config.yml`의 `twitter_user` 값을 이용해 메타 태그를 입력한다. 이 역시 입력하지 않아도 된다.

[Facebook Insights]: https://www.facebook.com/insights/

Octopress에서 사이트에 메타 태그를 추가하는 방법은 간단하다. 일단 `source/_includes/custom/head.html` 파일에 다음 코드를 추가하자.

{% raw %}
``` html
...
<!-- Social media content metadata -->
{% if site.facebook_app_id %}
  <meta property="fb:admins" content="{{ site.facebook_app_id }}">
  <meta property="og:title" content="{% if page.title %}{{ page.title }}{% else %}{{ site.title }}{% endif %}">
  <meta property="og:site_name" content="{{ site.title }}">
  <meta property="og:url" content="{% if canonical %}{{ canonical }}{% else %}{{ site.url }}{% endif %}">
  <meta property="og:description" content="{{ description | strip_html | condense_spaces | truncate:200 }}">
  {% if site.facebook_page %}
    <meta property="article:author" content="{{ site.facebook_page }}">
  {% endif %}
  {% if page.facebook.image %}
    <meta property="og:image" content="{{ page.facebook.image }}">
  {% endif %}
{% endif %}
<meta name="twitter:card" content="{% if page.twitter_card.type %}{{ page.twitter_card.type }}{% else %}summary{% endif %}">
{% if site.twitter_user %}
  <meta name="twitter:site" content="{{ site.twitter_user }}">
{% endif %}
<meta name="twitter:title" content="{% if page.title %}{{ page.title | truncate:70 }}{% else %}{{ site.title | truncate:70 }}{% endif %}">
<meta name="twitter:description" content="{{ description | strip_html | condense_spaces | truncate:200 }}">
{% if page.twitter_card.creator %}
  <meta name="twitter:creator" content="{{ page.twitter_card.creator }}">
{% elsif site.twitter_user %}
  <meta name="twitter:creator" content="{{ site.twitter_user }}">
{% endif %}
{% if page.twitter_card.image %}
  {% if page.twitter_card.type == 'gallery' %}
    <meta name="twitter:image0" content="{{ page.twitter_card.image }}">
    <meta name="twitter:image1" content="{{ page.twitter_card.image1 }}">
    <meta name="twitter:image2" content="{{ page.twitter_card.image2 }}">
    <meta name="twitter:image3" content="{{ page.twitter_card.image3 }}">
  {% else %}
    <meta name="twitter:image:src" content="{{ page.twitter_card.image }}">
    {% if page.twitter_card.type == 'photo' %}
      {% if page.twitter_card.width %}
        <meta name="twitter:image:width" content="{{ page.twitter_card.width }}">
      {% endif %}
      {% if page.twitter_card.height %}
        <meta name="twitter:image:height" content="{{ page.twitter_card.height }}">
      {% endif %}
    {% endif %}
  {% endif %}
{% endif %}
```
{% endraw %}

페이스북에 링크를 첨부해 상태를 올리면 메타 태그 기반으로 미리보기를 생성해 준다. 다만 트위터의 경우 사이트 등록이 필요하다. [카드 검사 도구][Card Validator] 페이지에서 사이트가 검사에 통과하면 도메인 인증 요청을 보낼 수 있다. 이 요청이 통과되면 트위터에서 사이트 링크를 트위터 카드로 만들어 보여준다.

추가로 설정 가능한 몇 가지 옵션에 대해 설명하겠다.

``` yaml
---
layout: post
title: "An example post"
date: 2014-02-24
comments: false
categories:
    - Example
description: This is an example post.
facebook:
    image: http://example.com/path/to/image.png
twitter_card:
    creator: twitter
    type: summary_large_image
    image: http://example.com/path/to/image.png
---
```

글에 `description` 태그를 사용하면 그 값이 description으로 사용된다. 만약 없다면 글 앞부분이 사용된다. `facebook` 태그 아래에 `image` 태그를 사용하면 페이스북의 미리보기 이미지로 사용된다. `twitter_card` 태그 아래의 `image`도 마찬가지이다. 추가로 `twitter_card` 태그 아래에 `type`을 명시할 수 있고, `creator` 태그를 사용하면 `_config.yml`의 `twitter_user` 대신 그 값을 사용한다. `facebook` 태그와 `twitter_card` 태그 모두 추가 옵션으로 입력하지 않아도 관계없다.

위 코드가 모든 트위터 카드를 지원하는 것은 아니다. 기본적으로 `twitter_card`의 `image` 태그를 입력하면 `summary`, `summary_large_image`, `photo` 타입을 사용할 수 있다. `photo` 타입은 추가적인 태그를 사용할 수 있다.

``` yaml
---
layout: post
title: "An example post"
date: 2014-02-24
comments: false
categories:
    - Example
description: This is an example post.
twitter_card:
    type: photo
    image: http://example.com/path/to/image.png
    width: 640
    height: 960
---
```

`width` 태그와 `height` 태그는 사진의 크기를 나타내며 이 두 태그의 입력은 옵션이다. 자세한 사항은 [Photo Card][] 페이지에서 확인하길 바란다.

`gallery` 타입의 경우 추가로 필요한 태그가 있으며 예제는 다음과 같다:

``` yaml
---
layout: post
title: "An example post"
date: 2014-02-24
comments: false
categories:
    - Example
description: This is an example post.
twitter_card:
    type: gallery
    image: http://example.com/path/to/image.png
    image1: http://example.com/path/to/image1.png
    image2: http://example.com/path/to/image2.png
    image3: http://example.com/path/to/image3.png
---
```

원래 [Gallery Card][]에 쓰이는 태그는 `image0`부터 `image3`까지지만 편의를 위해 `image0`은 `image` 태그로 대신했다. 이미지 4장의 주소가 모두 필요하다. 이 외의 카드 종류들은 필요로 하는 태그의 종류가 많고 일일이 입력하기에도 불편할 것 같아 구현하지 않았다.
