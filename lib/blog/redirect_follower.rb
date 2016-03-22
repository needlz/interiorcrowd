module Blog

  class RedirectFollower

    def initialize(options)
      @session = options[:session]
      @faraday_response = options[:faraday_response]
      @default_referer = options[:default_referer]
      @blog_path = options[:blog_path]
      @original_url = options[:original_url]
      @params = options[:params]
      @last_url = @original_url
    end

    def final_response(&on_request)
      @do_request = on_request
      @faraday_response = on_request.call(original_url)
      handle_response
    end

    private

    attr_reader :faraday_response, :default_referer, :blog_path, :original_url, :params, :session

    def handle_response
      if responded_with_redirect?(faraday_response)
        handle_redirect
      else
        if faraday_response.body.include?('If you feel this is in error please contact your hosting providers abuse department') && !session[:use_blog_proxy]
          session[:use_blog_proxy] = true
          @faraday_response = @do_request.call(@last_url)
          handle_response
        else
          faraday_response
        end
      end
    end

    def handle_redirect
      redirect = faraday_response.headers[:location]
      redirect = redirect.gsub(/(\?|&)?icrowd_app=yes/, '')
      if relative_path?(redirect)
        referer = get_referer_path(redirect)
        redirect = referer + '/' + redirect
      end
      if equal_to_request_url_with_slash?(redirect)
        @last_url = redirect
        @faraday_response = @do_request.call(redirect)
        return final_response(&@do_request)
      end
      redirect_matches = redirect.match(/(#{ Regexp.escape(URI(default_referer).host) })\/(.+)/)
      redirect_part = redirect_matches[2] if redirect_matches
      redirect_part[0] = '' if redirect_part[0] == '/' if redirect_part
      redirect = blog_path + redirect_part.to_s
      redirect
    end

    def responded_with_redirect?(faraday_response)
      faraday_response.status / 100 == 3
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
