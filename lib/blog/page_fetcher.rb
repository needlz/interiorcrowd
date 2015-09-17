module Blog

  class PageFetcher

    attr_reader :url

    def initialize(options)
      @env = options[:env]
      @url = options[:url]
      @method = options[:method]
      @params = options[:params].merge(icrowd_app: 'yes')
      @session = options[:session]
      @blog_path = options[:blog_path]
    end

    def get_response(url = nil)
      response = make_request(url || @url)
      check_redirect(response)
    end

    private

    attr_reader :method, :params, :session, :blog_path, :env

    def make_request(url)
      conn = Faraday.new(url) do |f|
        f.use FaradayMiddleware::FaradayCookies, session: session
        f.response :logger if Settings.log_requests_to_blog
        f.request :url_encoded
        forward_headers(f)
        f.adapter Faraday.default_adapter
      end

      if method == :post
        conn.post('', params)
      else
        conn.get('', params)
      end
    end

    def responded_with_redirect?(response)
      response.status / 100 == 3
    end

    def equal_to_request_url_with_slash?(url)
      uri = URI(url)
      original_uri = URI(@url)
      request_path = url.split('?').first
      request_params = CGI::parse(uri.query) if uri.query
      request_fragment = uri.fragment
      original_request_path = @url.to_s.split('?').first
      original_request_params = CGI::parse(original_uri.query) if original_uri.query
      original_request_fragment = original_uri.fragment

      request_path.match(/^#{ Regexp.escape(original_request_path) }\/$/) &&
          (request_params == original_request_params) &&
          (request_fragment == original_request_fragment)
    end

    def forward_headers(r)
      ['ACCEPT', 'ACCEPT_LANGUAGE', 'USER_AGENT'].each do |header|
        r.headers[header.dasherize] = env["HTTP_#{ header }"] if env["HTTP_#{ header }"]
      end
      ['CONTENT_TYPE'].each do |header|
        r.headers[header.dasherize] = env["#{ header }"] if env["#{ header }"]
      end
    end

    def check_redirect(response)
      if responded_with_redirect?(response)
        redirect = response.headers[:location]
        redirect = redirect.gsub(/\??icrowd_app=yes/, '')
        if !redirect.match(/^http(s?):/)
          if redirect[0] == '/'
            referer = Settings.external_urls.blog.url
          else
            referer = params['_wp_http_referer'] || ''
            uri = URI.join(Settings.external_urls.blog.url, referer).to_s
            referer = uri
            uri_matches = uri.match %r[^(http://[^/]*|[^/]*)(/[^/]+($|\?))]
            referer = uri_matches[1] if uri_matches
          end
          redirect = referer + '/' + redirect
        end
        if equal_to_request_url_with_slash?(redirect)
          response = make_request(redirect)
          return check_redirect(response)
        end
        redirect_matches = redirect.match(/(#{ Regexp.escape(URI(Settings.external_urls.blog.url).host) })\/(.+)/)
        redirect_part = redirect_matches[2] if redirect_matches
        redirect_part[0] = '' if redirect_part[0] == '/' if redirect_part
        redirect = blog_path + redirect_part.to_s
        redirect
      else
        response
      end
    end
  end

end
