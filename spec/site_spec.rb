# frozen_string_literal: true

require 'jekyll'
require 'fileutils'
require 'tmpdir'

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
    title = Jekyll::Utils.slugify(actual.data['slug'],
                                  mode: 'pretty', cased: true)

    expect(actual.url).to eq("/#{year}/#{month}/#{day}/#{title}/")
  end
  failure_message do |actual|
    "expected #{actual.url} to have UTC date"
  end
end

RSpec.describe '_site' do
  let(:site_dir) { Dir.mktmpdir }
  let(:site) do
    Jekyll::Site.new(
      Jekyll.configuration('destination': site_dir, 'serving': false)
    )
  end

  after { FileUtils.remove_entry(site_dir) }

  describe 'timezone' do
    it 'uses UTC instead of local timezone' do
      site.process
      expect(site.posts.docs).to all(be_utc_post)
      expect(site.posts.docs).to all(have_utc_filename)
      expect(site.posts.docs).to all(have_utc_url)
    end
  end
end
