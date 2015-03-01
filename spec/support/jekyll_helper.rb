require 'jekyll'

module JekyllHelper
  def site
    Jekyll::Site.new(Jekyll.configuration)
  end

  def dest_dir(*subdirs)
    File.join(site.config['destination'], *subdirs)
  end
end
