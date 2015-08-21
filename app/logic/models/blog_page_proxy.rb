class BlogPageProxy

  BLOG_NAMESPACE = 'blog'

  BLOG_PAGE_PARTS_SELECTORS = {
      head: ['head'],
      body: ['#content', 'body'],
      header: ['.rst-bottom-header']
  }

  def initialize(response_body)
    @response_body = response_body

    blog_host = URI(Settings.external_urls.blog.url).host
    @blog_regex = /\/\/(#{ Regexp.escape(blog_host) })/
  end

  def rendering_params
    locals = {}
    BLOG_PAGE_PARTS_SELECTORS.keys.each do |part|
      locals.merge!(part => read_blog[part])
    end
    locals
  end

  private

  attr_reader :response_body, :blog_regex

  def read_blog
    return @blog_params if @blog_params
    @blog_params = {}
    parse_dom
    extract_parts
    @blog_params
  end

  def parse_dom
    @blog_page_dom = Nokogiri::HTML(response_body)
  end

  def extract_parts
    BLOG_PAGE_PARTS_SELECTORS.keys.each do |part|
      part_dom = nil
      BLOG_PAGE_PARTS_SELECTORS[part].each do |selector|
        break if selector == 'head' && !load_head_content?
        part_dom = @blog_page_dom.css(selector)
        break if part_dom.present?
      end
      if part_dom.present?
        replace_links(part_dom)
        part_content = part_dom.first.children.to_s
      else
        part_content = ''
      end
      @blog_params.merge!(part => part_content)
    end
  end

  def load_head_content?
    @blog_page_dom.css('#content').present?
  end

  def replace_links(dom_element)
    dom_element.css('a').each { |link| replace_link(link, 'href') }
    dom_element.css('form').each { |form| replace_link(form, 'action') }
  end

  def replace_link(element, attribute)
    element[attribute] = element[attribute].gsub(blog_regex, "//#{ Settings.app_host }/#{ BLOG_NAMESPACE }")
  end

end
