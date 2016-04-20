require 'faraday_middleware'

class BlogController < ApplicationController

  [:blog, :designers_blog].each do |blog_symbol|
    define_method "#{ blog_symbol }_root" do
      @login_required = blog_symbol == :designers_blog && current_user.designer?
      @external_host = host_of_blog(blog_symbol)
      @external_url = @external_host
      @setup_viglink = true
      do_request(:get, blog_symbol, get_params)
    end

    define_method "#{ blog_symbol }_page" do
      @setup_viglink = true
      subpage_action(blog_symbol, :get)
    end

    define_method "#{ blog_symbol }_page_post" do
      subpage_action(blog_symbol, :post)
    end
  end

  def justines_story
    @external_host = Settings.external_urls.blog.blog_url
    set_url
    render_get_response(blog_page_url(blog_page_path: ''))
  end

  private

  def host_of_blog(blog_symbol)
    Settings.external_urls.blog.send("#{ blog_symbol }_url")
  end

  def subpage_action(blog_symbol, http_method)
    @login_required = blog_symbol == :designers_blog && current_user.designer?
    @external_host = host_of_blog(blog_symbol)
    @external_url = URI.join(@external_host, params[:blog_page_path])
    do_request(http_method, blog_symbol, get_params)
  end

  def do_request(method, blog_symbol, request_params = nil)
    begin
      @internal_blog_namespace = send("#{ blog_symbol }_page_path", blog_page_path: '')
      blog_path = send("#{ blog_symbol }_page_url", blog_page_path: '')
      @external_url = URI.decode(@external_url.to_s)
      @external_url = @external_url + '?' + env['QUERY_STRING'] if env['QUERY_STRING'].present?
      @blog_page_fetcher = Blog::PageFetcher.new(url: @external_url,
                                              params: request_params,
                                              env: env,
                                              method: method,
                                              session: session,
                                              blog_path: blog_path,
                                              request: request,
                                              default_referer: @external_host,
                                              cookies: cookies)

      @response = @blog_page_fetcher.get_response

      2.times do # one request is sometimes not enough because of cookies warning from blog
        if need_to_log_in?
          @response = login(blog_path)
        end
      end

      if @response.kind_of? Faraday::Response
        response_body = @response.body
      else
        return redirect_to @response
      end
    rescue OpenURI::HTTPError
      return raise_404
    end
    render_blog_page(response_body)
  end

  def need_to_log_in?
    @login_required && @response.kind_of?(Faraday::Response) && (login_form_present? || no_personal_panel?)
  end

  def no_personal_panel?
    extname = File.extname(URI(@external_url).path)[1..-1]
    mime_type = Mime::Type.lookup_by_extension(extname)
    content_type = mime_type.to_s unless mime_type.nil?
    !request.xhr? && (content_type == 'text/html' || !content_type) && @response.body.exclude?('id="wp-admin-bar-my-account"')
  end

  def login_form_present?
    @response.body.include?('<form name="loginform" id="loginform"')
  end

  def login(blog_path)
    login_params = {
      log: current_user.blog_username,
      pwd: current_user.blog_password,
      rememberme: 'forever',
      'wp-submit' => 'Log In',
      testcookie: 1,
      redirect_to: @external_url
    }
    login_request = Blog::PageFetcher.new(url: URI.join(@external_host, '/wp-login.php'),
                          params: login_params,
                          env: env,
                          method: :post,
                          session: session,
                          blog_path: blog_path,
                          request: request,
                          default_referer: @external_host,
                          cookies: cookies)
    login_request.get_response
  end

  def render_blog_page(content)
    @admin_page = @external_url.match %r[/wp-admin($|/)]
    @no_global_css = true
    extname = File.extname(URI(@external_url).path)[1..-1]
    mime_type = Mime::Type.lookup_by_extension(extname)
    content_type = mime_type.to_s unless mime_type.nil?
    if content_type #file with extension
      render text: content, content_type: content_type
    else
      locals = Blog::PageParser.new(response_body: content,
                                    form_authenticity_token: form_authenticity_token,
                                    internal_blog_namespace: @internal_blog_namespace).rendering_params
      if request.xhr?
        render text: locals[:text]
      else
        if @admin_page
          AdminBlogPage.render(locals, self)
        else
          DefaultBlogPage.render(locals, self)
        end
      end
    end
  end

  def set_url
    @external_url = Settings.external_urls.blog[action_name]
  end

  def get_params
    raw_params = params.except(:action, :controller, :blog_page_path, :utf8, :authenticity_token)
    return raw_params if env['QUERY_STRING'].blank? && env['rack.request.form_vars'].blank?
    if env['QUERY_STRING'].present?
      uri_params = CGI::parse(env['QUERY_STRING'])
    else
      uri_params = CGI::parse(env['rack.request.form_vars'])
    end
    p 'uri params', Hash[uri_params.map{ |k,v| [k, v[0]] }] if Settings.log_requests_to_blog
    raw_params.merge!(Hash[uri_params.map{ |k,v| [k, v[0]] }])
    raw_params
  end

end
