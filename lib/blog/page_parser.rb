module Blog

  class PageParser

    DESIGNERS_BLOG_NAMESPACE = 'blog/designers'
    BLOG_NAMESPACE = 'blog'

    BLOG_REGEX = /\/\/(#{ Regexp.escape(URI(Settings.external_urls.blog.blog_url).host) })/
    BLOG_PATH_REPLACEMENT = "//#{ Settings.app_host }/#{ BLOG_NAMESPACE }"

    DESIGNERS_BLOG_REGEX = /\/\/(#{ Regexp.escape(URI(Settings.external_urls.blog.designers_blog_url).host) })/
    DESIGNERS_BLOG_PATH_REPLACEMENT = "//#{ Settings.app_host }/#{ DESIGNERS_BLOG_NAMESPACE }"

    BLOG_PAGE_PARTS_SELECTORS = {
        head: ['head'],
        body: ['body'],
        header: ['.rst-bottom-header']
    }

    def initialize(options)
      @response_body = options[:response_body]
      @form_authenticity_token = options[:form_authenticity_token]
      @internal_blog_namespace = options[:internal_blog_namespace]
    end

    def rendering_params
      locals = {}
      BLOG_PAGE_PARTS_SELECTORS.keys.each do |part|
        locals.merge!(part => read_blog[part])
      end
      locals.merge!(page_html_attributes: read_blog['page_html_attributes'],
                    page_body_attributes: read_blog['page_body_attributes'])
      locals.merge!(text: response_body)
      locals
    end

    private

    attr_reader :response_body

    def read_blog
      return @blog_params if @blog_params
      @blog_params = {}
      parse_dom
      extract_parts
      @blog_params
    end

    def designers_blog?
      @designers_blog
    end

    def parse_dom
      response_body.gsub!(%r['/wp-admin/admin-ajax.php'], "\'#{ @internal_blog_namespace }wp-admin/admin-ajax.php\'")
      response_body.gsub!(%r[(//blog.interiorcrowd.com)([^"]+)([^\.]\.(?!(jpg|jpeg|png|gif)))(")], '/blog\2\3\5')
      response_body.gsub!(%r[(//designers.interiorcrowd.com)([^"]+)([^\.]\.(.+))(")], '/blog/designers\2\3\5')
      response_body.gsub!(%r[(")(/wp-content.+ajax-loader\.gif)], '\1http://blog.interiorcrowd.com\2')
      p response_body if Settings.log_requests_to_blog
      @blog_page_dom = Nokogiri::HTML(response_body)
      replace_links(@blog_page_dom)
      @blog_page_dom
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
          part_content = part_dom.first.to_s
        else
          part_content = ''
        end
        @blog_params.merge!(part => part_content)
      end
      %w[html body].each do |outer_part|
        @blog_params["page_#{ outer_part }_attributes"] = @blog_page_dom.css(outer_part).first.attributes if @blog_page_dom.try(:css, outer_part).try(:first)
      end
    end

    def load_head_content?
      true
    end

    def replace_links(dom_element)
      dom_element.css('a').each { |link| replace_link(link, 'href') }
      dom_element.css('form').each { |form| replace_link(form, 'action'); append_authenticity_token(form) }
      dom_element.css('link').each { |link| replace_link(link, 'href') if ['canonical', 'next'].include?(link['rel']) }
      dom_element.css('div[data-site-url]').each { |div| replace_link(div, 'data-site-url') }
    end

    def replace_link(element, attribute)
      if element[attribute]
        element[attribute] = element[attribute].gsub(BLOG_REGEX, BLOG_PATH_REPLACEMENT)
        element[attribute] = element[attribute].gsub(DESIGNERS_BLOG_REGEX, DESIGNERS_BLOG_PATH_REPLACEMENT)
      end
    end

    def append_authenticity_token(form)
      form << "<input name=\"utf8\" type=\"hidden\" value=\"✓\"><input name=\"authenticity_token\" type=\"hidden\" value=\"#{ @form_authenticity_token }\">"
    end

  end

end
