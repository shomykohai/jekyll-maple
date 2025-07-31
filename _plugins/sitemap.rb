require 'fileutils'
require 'jekyll'
require 'rexml/document'
require 'uri'

module Jekyll
  class SitemapGenerator < Generator
    safe true
    priority :lowest

    def generate(site)
      sitemap_path = File.join(site.dest, 'sitemap.xml')

      banned_extensions = site.config.dig('maple', 'sitemap', 'banned_extensions') || []
      allowed_extensions = site.config.dig('maple', 'sitemap', 'allowed_extensions') || []
      banned_routes = site.config.dig('maple', 'sitemap', 'banned_routes') || []
      included_routes = site.config.dig('maple', 'sitemap', 'included_pages') || []

      site_url = site.config['url'] || ''
      prepend_url = site_url[%r{^https?://}] ? '' : 'https://'

      urls = []
      

      # Process pages
      site.pages.each do |page|
        next if page.url == '/sitemap.xml'
        next if page.data['sitemap'] == false
        next if page.url.include?('/tag/') && site.config.dig('maple', 'sitemap', 'exclude_tags') == true
        
        ext = File.extname(page.url).sub('.', '')
        is_dir_url = page.url.end_with?('/')

        next if banned_extensions.include?(ext)
        next unless allowed_extensions.include?(ext) || is_dir_url

        urls << build_url_entry(site_url, page, prepend_url)
      end

      site.posts.docs.each do |post|
        next if post.data['sitemap'] == false

        urls << build_url_entry(site_url, post, prepend_url, priority: '1.0')
      end


      included_routes.each do |route|
        urls << {
          loc: URI.join(prepend_url + site_url, route).to_s,
          priority: '1.0'
        }
      end
  
      xml = build_sitemap_xml(urls)

      File.write(sitemap_path, xml)
      site.keep_files ||= []
      site.keep_files << 'sitemap.xml'
    end

    private

    def build_url_entry(site_url, item, prepend_url, priority: nil)
      full_url = URI.join(prepend_url + site_url, item.url.sub(/index\.html$/, '')).to_s
      lastmod = item.data['last_modified_at'] || item.data['date']

      {
        loc: full_url,
        lastmod: lastmod&.to_time&.utc&.iso8601,
        priority: priority || item.data['priority'] || (full_url == site_url ? '1.0' : '0.9')
      }
    end

    def build_sitemap_xml(urls)
      doc = REXML::Document.new
      doc << REXML::XMLDecl.new

      urlset = doc.add_element('urlset', {
        'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9'
      })

      urls.each do |entry|
        url = urlset.add_element('url')
        url.add_element('loc').text = entry[:loc]
        url.add_element('lastmod').text = entry[:lastmod] if entry[:lastmod]
        url.add_element('priority').text = entry[:priority]
      end

      output = ''
      formatter = REXML::Formatters::Pretty.new(2)
      formatter.compact = true
      formatter.write(doc, output)
      output
    end
  end
end
