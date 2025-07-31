# A small jekyll plugin to generate a markdown Table of contents based on the 
# headings in the content of a page.

module Jekyll
  class TOCBlock < Liquid::Tag
    def render(context)
      page = context.registers[:page]
      content = page['content'] || ''

      html = Kramdown::Document.new(content).to_html

      # Extracts the following: [level, id, text]
      # where level is the heading level (1-6), the id is what 
      # jekyll automatically generates based on the heading text, and
      # text is the actual heading text.
      # Example: <h2 id="my-heading">My Heading</h2> -> [2, "my-heading", "My Heading"]
      headings = html.scan(/<h([1-6])(?:[^>]*\sid=["']([^"']+)["'])?[^>]*>(.*?)<\/h\1>/im)

      return '' if headings.empty?

      # Find minimum heading level used in content to
      # ensure it doesn't become too nested.
      min_level = headings.map { |h| h[0].to_i }.min

      toc = ''
      current_level = min_level - 1
      stack = []

      headings.each do |level_str, id, text|
        level = level_str.to_i
        id ||= text.strip.downcase.gsub(/[^\w]+/, '-')
        # Removes possible HTML tags in the text
        clean_text = text.gsub(/<\/?[^>]*>/, '').strip

        
        if level > current_level
          (level - current_level).times do
            toc << "<ul>"
            stack.push("</ul>")
          end
        elsif level < current_level
          (current_level - level).times do
            toc << "</li>"
            toc << stack.pop
          end
          toc << "</li>"
        else
          toc << "</li>" if current_level >= min_level
        end

        toc << "<li><a href=\"##{id}\">#{clean_text}</a>"

        current_level = level
      end

      while current_level >= min_level
        toc << "</li>"
        toc << stack.pop
        current_level -= 1
      end

      toc
    end
  end
end

Liquid::Template.register_tag('toc', Jekyll::TOCBlock)
