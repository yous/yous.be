---
layout: post
title: "Moving Timezone to UTC in Jekyll"
date: 2015-09-05 12:39:19 +0000
categories:
    - Jekyll
description: Migrating every post to UTC timezone.
keywords: jekyll, timezone, utc, rspec
redirect_from: /p/20150905/
---

At the very first, I haven't think about the timezone of my blog. I had used to
generate my blog on my local machine and deploy manually. At that time every
content is released based on KST timezone, which is GMT+9.

Right after that I tried to deploy my blog through Travis CI, I realized that
something went wrong. Travis CI uses UTC by default, so the URL of every post
between 0AM and 9AM was shifted by one day backward. I
[had to modify](https://github.com/yous/yous.be/commit/0bd96e27320a82c9fee0d1413c744300d1e1af08)
`/etc/timezone` or set environment variable `TZ` to restore the URLs.

Yes, this can solve the problem I faced. But should I really use the KST for
this whole blog? It'll be nice if I can show the time based on timezone of each
client, but I won't be able to handle the date part of the post URL as well. So
I decided to move the timezone of this site to UTC, global standard at least.

<!-- more -->

First I should write some tests for the migration since I want to change URLs by
only one push. You can access current posts by using `jekyll` gem. Place
`spec/support/jekyll_helper.rb` with:

``` ruby
require 'jekyll'

module JekyllHelper
  def site
    unless @site
      @site = Jekyll::Site.new(
        Jekyll.configuration('serving' => false, 'full_rebuild' => true))
      @site.process
    end
  end
end
```

Note `@site.process`. This makes you be able to access `@site.posts`. The basic
test is simple. I placed this on `spec/site_spec.rb`:

``` ruby
RSpec.describe '_site' do
  include JekyllHelper

  describe 'timezone' do
    it 'uses UTC instead of local timezone' do
      expect(site.posts).to all(be_utc_post)
      expect(site.posts).to all(have_utc_filename)
      expect(site.posts).to all(have_utc_url)
    end
  end
end
```

So, what's the `be_utc_post`, `have_utc_filename`, and `have_utc_url`? Each of
them is RSpec custom matcher. I separated the validation into three parts.

1. Does the `date` object of the post have UTC timezone?
2. Does the post have filename with the UTC date?
3. Does the generated URL have the UTC date?

So the each matcher is like following:

``` ruby
RSpec::Matchers.define :be_utc_post do
  match do |actual|
    expect(actual.date.zone).to eq('UTC')
  end
  failure_message do |actual|
    "expected #{actual.date} to have UTC timezone"
  end
end

RSpec::Matchers.define :have_utc_filename do
  match do |actual|
    date = actual.date.utc
    year = date.strftime('%Y')
    month = date.strftime('%m')
    day = date.strftime('%d')

    expect(actual.name)
      .to eq("#{year}-#{month}-#{day}-#{actual.slug}#{actual.ext}")
  end
  failure_message do |actual|
    "expected #{actual.name} to have UTC date"
  end
end

RSpec::Matchers.define :have_utc_url do
  match do |actual|
    date = actual.date.utc
    year = date.strftime('%Y')
    month = date.strftime('%m')
    day = date.strftime('%d')

    expect(actual.url).to eq("/#{year}/#{month}/#{day}/#{actual.slug}/")
  end
  failure_message do |actual|
    "expected #{actual.url} to have UTC date"
  end
end
```

Note that `"/#{year}/#{month}/#{day}/#{actual.slug}/"` is based on my
`permalink` setting of `_config.yml` in Jekyll, so you may have to change the
template appropriately.

**Update**: Jekyll released 3.0.0, and there were some changes on
`Jekyll::Post`. Following code is updated version of spec code. Also you can
track the file on
[GitHub](https://github.com/yous/yous.be/blob/source/spec/site_spec.rb).

``` ruby
RSpec::Matchers.define :be_utc_post do
  match do |actual|
    expect(actual.date.zone).to eq('UTC')
  end
  failure_message do |actual|
    "expected #{actual.date} to have UTC timezone"
  end
end

RSpec::Matchers.define :have_utc_filename do
  match do |actual|
    date = actual.date.utc
    year = date.strftime('%Y')
    month = date.strftime('%m')
    day = date.strftime('%d')
    slug = actual.data['slug']
    ext = actual.data['ext']

    expect(actual.basename)
      .to eq("#{year}-#{month}-#{day}-#{slug}#{ext}")
  end
  failure_message do |actual|
    "expected #{actual.basename} to have UTC date"
  end
end

RSpec::Matchers.define :have_utc_url do
  match do |actual|
    date = actual.date.utc
    year = date.strftime('%Y')
    month = date.strftime('%m')
    day = date.strftime('%d')
    slug = Jekyll::Utils.slugify(actual.data['slug'])

    expect(actual.url).to eq("/#{year}/#{month}/#{day}/#{slug}/")
  end
  failure_message do |actual|
    "expected #{actual.url} to have UTC date"
  end
end

RSpec.describe '_site' do
  include JekyllHelper

  describe 'timezone' do
    it 'uses UTC instead of local timezone' do
      expect(site.posts.docs).to all(be_utc_post)
      expect(site.posts.docs).to all(have_utc_filename)
      expect(site.posts.docs).to all(have_utc_url)
    end
  end
end
```

Tests are ready, so now we start migrating. See 'Time Zone' part of
[the documentation of Jekyll configuration](http://jekyllrb.com/docs/configuration/#global-configuration).

> Set the time zone for site generation. This sets the `TZ` environment
> variable, which Ruby uses to handle time and date creation and manipulation.
> Any entry from the [IANA Time Zone Database](http://en.wikipedia.org/wiki/Tz_database)
> is valid, e.g. `America/New_York`. A list of all available values can be found
> [here](http://en.wikipedia.org/wiki/List_of_tz_database_time_zones). The
> default is the local time zone, as set by your operating system.

So when you add `timezone: UTC` to your `_config.yml`, you're almost done!
Remained things are boring file renames and making backward redirect links,
using [jekyll-redirect-from](https://github.com/jekyll/jekyll-redirect-from).

You can see the full changes on
[this commit](https://github.com/yous/yous.be/commit/4aae28ea371af67cb099a249f2c4f7a5bb1be723).
