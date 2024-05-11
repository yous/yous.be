# frozen_string_literal: true

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

require 'html-proofer'
desc 'Validate HTML files'
task :proof do
  HTMLProofer.check_directory(
    '_site',
    typhoeus: {
      connecttimeout: 30,
      timeout: 60
    },
    cache: {
      timeframe: { external: '4w' }
    },
    checks: ['Links', 'Images', 'Scripts', 'Favicon', 'OpenGraph'],
    enforce_https: false,
    ignore_status_codes: [302],
    ignore_urls: [
      %r{^https?://localhost},
      %r{^https?://t\.co/},
      %r{^https?://twitter\.com},
      %r{^https?://web\.archive\.org/web/},
      # _include/fonts.html
      %r{^https://fonts\.gstatic\.com$},
      # /about/
      %r{^https://tweetdeck\.twitter\.com},
      # /2013/02/18/ios-6.1-music-album-shuffle/
      %r{^http://www\.hackint0sh\.org/free-toolchain-software-126/req-album-shuffle-option-18867\.htm},
      # /2013/12/04/tomorrow-theme-in-octopress/
      %r{^http://devspade\.com/blog/2013/08/06/fixing-gist-embeds-in-octopress/},
      # /2014/01/20/ghost-in-the-shellcode-2014-inview-write-up/
      %r{^https://2014\.ghostintheshellcode\.com/inview-324b8fb59c14da0d5ca1fe2c31192d80cec8e155},
      # /2014/02/24/support-facebook-open-graph-and-twitter-cards-on-octopress/
      %r{^https://cards-dev\.twitter\.com/validator},
      %r{^https://dev\.twitter\.com/docs/cards/types/photo-card},
      %r{^https://dev\.twitter\.com/docs/cards/types/gallery-card},
      %r{^https://dev\.twitter\.com/docs/cards/types/product-card},
      %r{^https://developers\.facebook\.com/docs/reference/opengraph/object-type/article},
      # /2014/03/04/design-details-paper-by-facebook/
      %r{^https://itunes\.apple\.com/us/app/paper-stories-from-facebook/id794163692},
      # /2014/03/27/twitter-link-bookmarklet/
      %r{^http://yoonjiman\.net/2014/03/25/twitter-profile-bookmarklet/},
      # /2014/05/15/how-to-configure-proguard-using-gradle/
      %r{^http://novafactory\.net/archives/2845},
      # /2014/12/25/christmasctf-2014-write-up/
      %r{^http://web-prob\.dkserver\.wo\.tc/letter_4f1ad94372c166c3cb9632ed5041849a/},
      %r{^http://web-prob\.dkserver\.wo\.tc/sqli_962a035aacf08966ffc7610957ac0c29/},
      %r{^http://988087853},
      %r{^http://58\.229\.6\.45},
      # /2016/10/11/hitcon-ctf-2016-rop-write-up/
      %r{^https://s3-ap-northeast-1\.amazonaws\.com/hitcon2016qual/rop\.iseq_a9ac4b7a1669257d0914ca556a6aa6d14b4a2092}
    ],
    swap_urls: {
      %r{^(//.*)} => 'https:\1',
      %r{^(https?://github\.com/[^#]+)#.*} => '\1'
    }
  ).run
end

desc 'Create a new post'
task :post, :title do |_t, args|
  if args.title
    title = args.title
  else
    print 'Enter a title for your post: '
    title = $stdin.gets.chomp
  end
  time = Time.now.utc
  slug = "#{time.strftime('%Y-%m-%d')}-#{title.downcase.gsub(/[^\w]+/, '-')}"
  filename = File.join(File.dirname(__FILE__), '_posts', "#{slug}.markdown")

  if File.exist?(filename)
    puts "#{filename} already exists."
    abort 'rake aborted!'
  end
  puts "Creating new post: #{filename}"
  File.open(filename, 'w') do |f|
    f.puts '---'
    f.puts 'layout: post'
    f.puts "title: \"#{title}\""
    f.puts "date: #{time.strftime('%Y-%m-%d %H:%M:%S %z')}"
    f.puts 'categories:'
    f.puts 'description:'
    f.puts 'keywords:'
    f.puts "redirect_from: /p/#{time.strftime('%Y%m%d')}/"
    f.puts '---'
  end
end
