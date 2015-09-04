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

  def do_request(method, request_params = nil)
    begin
      @url = URI.decode(@url.to_s)
      @url = @url + '?' + env['QUERY_STRING'] if env['QUERY_STRING'].present?
      blog_page_fetcher = Blog::PageFetcher.new(url: @url,
                                              params: request_params,
                                              env: env,
                                              method: method,
                                              session: session,
                                              blog_path: blog_page_url(blog_page_path: ''))

      response = blog_page_fetcher.get_response

      if response.kind_of? Faraday::Response
        response_body = response.body
      else
        return redirect_to response
      end
    rescue OpenURI::HTTPError
      return raise_404
    end
    render_blog_page(response_body)
  end

  def render_blog_page(content)
    @admin_page = @url.match %r[/wp-admin($|/)]
    locals = Blog::PageParser.new(content, form_authenticity_token).rendering_params
    @no_global_css = true
    if @admin_page
      AdminBlogPage.render(locals, self)
    else
      DefaultBlogPage.render(locals, self)
    end
  end

  def set_url
    @url = Settings.external_urls.blog[action_name]
  end

  def get_params
    raw_params = params.except(:action, :controller, :blog_page_post_path, :blog_page_path, :utf8, :authenticity_token)
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
