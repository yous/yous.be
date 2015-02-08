module Jekyll
  module Archives
    module ArchiveLinkFilters
      def category_links(categories)
        categories.map { |c| category_link(c) }.join(', ')
      end

      def category_link(category)
        site = @context.registers[:site]
        template = site.config['jekyll-archives']['permalinks']['category']
        url = URL.new({
          template: template,
          placeholders: { name: Utils.slugify(category) }
        }).to_s

        "<a href=\"#{site.baseurl}#{url}\">#{category}</a>"
      end
    end
  end
end

Liquid::Template.register_filter(Jekyll::Archives::ArchiveLinkFilters)
