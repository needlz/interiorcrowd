require 'faraday'
require 'set'

module FaradayMiddleware

  class FaradayCookies < Faraday::Middleware

    def initialize(app, options = {})
      super(app)
      @session = options.delete(:session)
      @cookies = options.delete(:cookies)
      @options = options
    end

    def call(env)
      set_cookies(env)
      get_cookies(env)
    end

    private

    def set_cookies(env)
      str = @session.try(:[], :blog_cookies) || ''
      @url = env[:url]

      @jar = HTTP::CookieJar.new
      s = StringIO.new(str)
      @jar.load(s, @url)

      @new_jar = HTTP::CookieJar.new
      s = StringIO.new(str)
      @new_jar.load(s, @url)

      cookie = HTTP::Cookie.cookie_value(@jar.cookies(@url))
      env[:request_headers]['Cookie'] ||= ''
      env[:request_headers]['Cookie'] = cookie if cookie.present?
    end

    def get_cookies(env)
      response = @app.call(env)

      response.on_complete do |response_env|
        set_cookie = response_env[:response_headers]['set-cookie']
        @new_jar.parse(set_cookie, @url) if response_env[:response_headers]['set-cookie']
        env[:cookies] = @jar

        if @cookies
          new_cookie_names = []
          @new_jar.each do |cookie|
            new_cookie_names << cookie.name
            @cookies[cookie.name] = { value: CGI::unescape(cookie.value), expires: cookie.expires, max_age: cookie.max_age, path: '/' }
          end
          @jar.each do |cookie|
            if new_cookie_names.exclude?(cookie.name)
              @cookies.delete(cookie.name.to_sym)
            end
          end
        end
        s = StringIO.new
        @jar.parse(set_cookie, @url) if set_cookie
        @jar.save(s, session: true)
        @session[:blog_cookies] = s.string
      end
      response
    end
  end
end
