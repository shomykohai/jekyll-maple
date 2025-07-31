module Jekyll
  class AuthorPage < Page
    def initialize(site, base, dir, author)
      @site = site
      @base = base
      @dir  = dir
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'author.html')

      self.data['title'] = "Posts by #{author['name']}"
      self.data['author'] = author
      self.data['author_id'] = author['id']
      self.data['permalink'] ||= "/author/#{author['id']}/"
    end
  end

  class AuthorPageGenerator < Generator
    safe true

    def generate(site)
      return unless site.config.dig('maple', 'enable_authors_page') && site.config.dig('maple', 'authors')
      authors = site.config.dig('maple', 'authors') || []
      authors.each do |author|
        site.pages << AuthorPage.new(site, site.source, File.join('authors', author['id']), author)
      end
    end
  end
end
