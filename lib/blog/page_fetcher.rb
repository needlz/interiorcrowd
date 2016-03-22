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
      request_url = url || @url
      redirect_follower = RedirectFollower.new(default_referer: Settings.external_urls.blog.url,
                                               blog_path: blog_path,
                                               original_url: request_url,
                                               params: params,
                                               session: session
      )
      redirect_follower.final_response do |url|
        make_request(url)
      end

    end

    private

    attr_reader :method, :params, :session, :blog_path, :env

    def make_request(url)
      conn = Faraday.new(url) do |f|
        f.use FaradayMiddleware::FaradayCookies, session: session
        f.use FaradayMiddleware::Gzip
        f.response :logger if Settings.log_requests_to_blog
        f.request :url_encoded
        forward_headers(f)
        f.options.params_encoder = Blog::FaradayParamsEncoder
        f.adapter Faraday.default_adapter
        f.proxy ENV["FIXIE_URL"] if (ENV["FIXIE_URL"].present? && session[:use_blog_proxy])
      end

      if method == :post
        conn.post('', params)
      else
        conn.get('', params)
      end
    end

    def forward_headers(r)
      ['ACCEPT', 'ACCEPT_LANGUAGE', 'USER_AGENT', 'CACHE_CONTROL', 'CONNECTION', 'ACCEPT_ENCODING', 'REFERER'].each do |header|
        r.headers[header.dasherize] = env["HTTP_#{ header }"] if env["HTTP_#{ header }"]
      end

      r.headers['REFERER'] = 'http://' + URI(Settings.external_urls.blog.url).host if r.headers['REFERER'].blank?
      r.headers['REFERER'].gsub!(Regexp.new("[^/]+" + Regexp.escape("/#{ Blog::PageParser::BLOG_NAMESPACE }")), URI(Settings.external_urls.blog.url).host)
      ['CONTENT_TYPE'].each do |header|
        r.headers[header.dasherize] = env["#{ header }"] if env["#{ header }"]
      end

    end
  end

end
