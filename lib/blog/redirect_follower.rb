module Blog

  class RedirectFollower

    BLOG_HOSTING_ACCESS_DENIED_MSG = 'If you feel this is in error please contact your hosting providers abuse department'

    def initialize(options)
      @faraday_response = options[:faraday_response]
      @default_referer = options[:default_referer]
      @blog_path = options[:blog_path]
      @original_url = options[:original_url]
      @params = options[:params]
      @last_url_in_redirects_chain = @original_url
      @plugins = options[:plugins]
    end

    def final_response(&on_request)
      @request_performer = on_request
      do_request
    end

    private

    attr_reader :faraday_response, :default_referer, :blog_path, :original_url, :params, :session

    attr_accessor :redirect

    def handle_response
      if responded_with_redirect?(faraday_response)
        handle_redirect
      else
        if turn_proxy_on?
          session[:use_blog_proxy] = true
          do_request
        else
          faraday_response
        end
      end
    end

    def turn_proxy_on?
      faraday_response.headers['content-type'] == 'text/html' &&
        faraday_response.body.include?(BLOG_HOSTING_ACCESS_DENIED_MSG) &&
        !session[:use_blog_proxy]
    end

    def handle_redirect
      self.redirect = faraday_response.headers[:location]
      self.redirect = redirect.gsub(/(\?|&)?icrowd_app=yes/, '')
      complement_redirect_location
      if equal_to_request_url_with_slash?(redirect)
        @last_url_in_redirects_chain = redirect
        return do_request
      end
      replace_host
      @plugins.each do |plugin|
        self.redirect = plugin.process(URI(redirect))
      end
      redirect.to_s
    end

    def complement_redirect_location
      if relative_path?(redirect)
        referer = get_referer_path(redirect)
        self.redirect = referer + '/' + redirect
      end
    end

    def do_request
      @faraday_response = @request_performer.call(@last_url_in_redirects_chain)
      handle_response
    end

    def responded_with_redirect?(faraday_response)
      faraday_response.status / 100 == 3
    end

    def replace_host
      redirect_matches = redirect.match(/(#{ Regexp.escape(URI(default_referer).host) })\/(.+)/)
      redirect_part = redirect_matches[2] if redirect_matches
      redirect_part[0] = '' if redirect_part && redirect_part[0] == '/'
      self.redirect = blog_path + redirect_part.to_s
    end

    def equal_to_request_url_with_slash?(url)
      uri = URI(url)
      original_uri = URI(original_url)
      request_path = url.split('?').first
      request_params = CGI::parse(uri.query) if uri.query
      request_fragment = uri.fragment
      original_request_path = original_url.to_s.split('?').first
      original_request_params = CGI::parse(original_uri.query) if original_uri.query
      original_request_fragment = original_uri.fragment

      request_path.match(/^#{ Regexp.escape(original_request_path) }\/$/) &&
          (request_params == original_request_params) &&
          (request_fragment == original_request_fragment)
    end

    def relative_path?(url)
      !url.match(/^http(s?):/)
    end

    def get_referer_path(relative_url)
      if relative_url[0] == '/'
        referer = default_referer
      else
        referer = params['_wp_http_referer'] || ''
        uri = URI.join(default_referer, referer).to_s
        referer = uri
        uri_matches = uri.match %r[^(http://[^/]*|[^/]*)(/[^/]+($|\?))]
        referer = uri_matches[1] if uri_matches
      end
      referer
    end

  end

end
