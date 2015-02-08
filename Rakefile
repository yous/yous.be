desc 'Create a new post'
task :post, :title do |t, args|
  if args.title
    title = args.title
  else
    print 'Enter a title for your post: '
    title = $stdin.gets.chomp
  end
  time = Time.now
  slug = "#{time.strftime('%Y-%m-%d')}-#{title.downcase.gsub(/[^\w]+/, '-')}"
  filename = File.join(File.dirname(__FILE__), '_posts', slug + '.markdown')

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
    f.puts 'comments: false'
    f.puts 'categories: '
    f.puts 'description: '
    f.puts 'keywords: '
    f.puts "redirect_from: /p/#{time.strftime('%Y%m%d')}"
    f.puts '---'
  end
end
