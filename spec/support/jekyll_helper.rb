require 'jekyll'

module JekyllHelper
  def site
    unless @site
      Jekyll::Commands::Clean.process({})
      @site = Jekyll::Site.new(
        Jekyll.configuration('serving' => false, 'full_rebuild' => true))
      @site.process
    end
    @site
  end
end
