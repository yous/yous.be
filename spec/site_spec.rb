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

RSpec.describe '_site' do
  include JekyllHelper

  describe 'timezone' do
    it 'uses UTC instead of local timezone' do
      expect(site.posts)
        .to all(be_utc_post.and have_utc_filename.and have_utc_url)
    end
  end
end
