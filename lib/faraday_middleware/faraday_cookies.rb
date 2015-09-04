require 'faraday'
require 'set'

module FaradayMiddleware

  class FaradayCookies < Faraday::Middleware

    def initialize(app, options = {})
      super(app)
      @session = options.delete(:session)
      @options = options
    end

    def call(env)
      set_cookies(env)
      get_cookies(env)
    end

    private

    def set_cookies(env)
      s = StringIO.new(@session.try(:[], :blog_cookies) || '')
      @jar = HTTP::CookieJar.new
      @url = env[:url]
      @jar.load(s, @url)
      cookie = HTTP::Cookie.cookie_value(@jar.cookies(@url))
      env[:request_headers]['cookie'] = cookie if cookie
    end

    def get_cookies(env)
      p 'request headers', env.request_headers if Settings.log_requests_to_blog
      p 'reuqest body', env.body if Settings.log_requests_to_blog
      response = @app.call(env)

      response.on_complete do |response_env|
        @jar.parse(response_env[:response_headers]['set-cookie'], @url) if response_env[:response_headers]['set-cookie']
        @jar.cleanup
        s = StringIO.new
        @jar.save(s, session: true)
        @session[:blog_cookies] = s.string
      end
      response
    end
  end
end
