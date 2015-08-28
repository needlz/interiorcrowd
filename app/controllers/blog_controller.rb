require 'faraday_middleware'

class BlogController < ApplicationController

  PAGES_WITH_IFRAME = [:designer_submission]
  EMBEDDED_PAGES = [:justines_story, :about_us]

  before_filter :set_url, only: EMBEDDED_PAGES + PAGES_WITH_IFRAME
  before_filter :render_get_response, only: EMBEDDED_PAGES

  def designer_submission
    render 'shared/_iframe', locals: { iframe_src: @url }
  end

  def justines_story; end

  def about_us; end

  def blog_page
    @url = URI.join(Settings.external_urls.blog.url, params[:blog_page_path])
    render_get_response
  end

  def blog_page_post
    @url = URI.join(Settings.external_urls.blog.url, params[:blog_page_post_path])
    render_post_response
  end

  def blog_root
    @url = Settings.external_urls.blog.url
    render_get_response
  end

  private

  def render_get_response
    do_request(:get, get_params)
  end

  def render_post_response
    do_request(:post, get_params)
  end

  def do_request(method, params = nil)
    begin
      @url = URI.decode(@url.to_s)
      @url = @url+ '?' + env['QUERY_STRING'] if env['QUERY_STRING'].present?

      response = get_response(@url, method, params)

      response = check_redirect(response, method, params)

      if response.kind_of? Faraday::Response
        response_body = response.body
      else
        return redirect_to response
      end
    rescue OpenURI::HTTPError
      return raise_404
    else
      render_blog_page(response_body)
    end
  end

  def render_blog_page(content)
    locals = BlogPageProxy.new(content, form_authenticity_token).rendering_params
    @no_global_css = true
    render 'shared/_blog_page', locals: locals, layout: 'application'
  end

  def set_url
    @url = Settings.external_urls.blog[action_name]
  end

  def get_response(url, method, params)
    conn = Faraday.new(url) do |f|
      f.use FaradayMiddleware::FaradayCookies, session: session
      f.response :logger if Rails.env.development?
      f.request :url_encoded
      f.adapter Faraday.default_adapter
    end

    if method == :post
      conn.post('', params)
    else
      conn.get
    end
  end

  def check_redirect(response, method, params)
    if responded_with_redirect?(response)
      redirect = response.headers[:location]
      if !redirect.match(/^http(s?):/)
        redirect = URI(Settings.external_urls.blog.url).host + '/' + redirect
      end
      if equal_to_request_url_with_slash?(redirect)
        response = get_response(redirect, method, params)
        return check_redirect(response, method, params)
      end
      redirect_matches = redirect.match(/(#{ Regexp.escape(URI(Settings.external_urls.blog.url).host) })\/(.+)/)
      redirect = blog_page_url(blog_page_path: '') + URI.decode(redirect_matches[2]) if redirect_matches
      return redirect
    else
      response
    end
  end

  def responded_with_redirect?(response)
    response.status / 100 == 3
  end

  def equal_to_request_url_with_slash?(url)
    url.match(/^#{ Regexp.escape(@url.to_s) }\/$/)
  end

  def get_params
    return if env['QUERY_STRING'].blank?
    p = CGI::parse(env['QUERY_STRING'])
    params.merge!( Hash[p.map{ |k,v| [k, v[0]] }])
  end

end
