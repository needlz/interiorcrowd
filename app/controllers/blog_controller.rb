require 'faraday_middleware'

class BlogController < ApplicationController

  EMBEDDED_PAGES = [:justines_story]

  before_filter :set_url, only: EMBEDDED_PAGES
  before_filter :render_get_response, only: EMBEDDED_PAGES

  def justines_story; end

  def blog_page
    @setup_viglink = true
    @url = URI.join(Settings.external_urls.blog.url, params[:blog_page_path])
    render_get_response(blog_page_url(blog_page_path: ''))
  end

  def designers_blog_page
    @setup_viglink = true
    @url = URI.join(Settings.external_urls.blog.designers_url, params[:blog_page_path])
    render_get_response(designers_blog_page_url(blog_page_path: ''))
  end

  def blog_page_post
    @url = URI.join(Settings.external_urls.blog.url, params[:blog_page_post_path])
    render_post_response(blog_page_url(blog_page_path: ''))
  end

  def designers_blog_page_post
    @url = URI.join(Settings.external_urls.blog.designers_url, params[:blog_page_post_path])
    render_post_response(designers_blog_page_url(blog_page_path: ''))
  end

  def blog_root
    @url = Settings.external_urls.blog.url
    render_get_response(blog_page_url(blog_page_path: ''))
  end

  def designers_blog_root
    @url = Settings.external_urls.blog.designers_url
    @url = @url + '/designer-community' if env['QUERY_STRING'].blank?
    render_get_response(designers_blog_page_url(blog_page_path: ''))
  end

  private

  def render_get_response(blog_path)
    do_request(:get, blog_path, get_params)
  end

  def render_post_response(blog_path)
    do_request(:post, blog_path, get_params)
  end

  def do_request(method, blog_path, request_params = nil)
    begin
      @url = URI.decode(@url.to_s)
      @url = @url + '?' + env['QUERY_STRING'] if env['QUERY_STRING'].present?
      blog_page_fetcher = Blog::PageFetcher.new(url: @url,
                                              params: request_params,
                                              env: env,
                                              method: method,
                                              session: session,
                                              blog_path: blog_path,
                                              request: request,
                                              default_referer: @url)

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
    @no_global_css = true
    extname = File.extname(URI(@url).path)[1..-1]
    mime_type = Mime::Type.lookup_by_extension(extname)
    content_type = mime_type.to_s unless mime_type.nil?
    if content_type #file with extension
      render text: content, content_type: content_type
    else
      locals = Blog::PageParser.new(content, form_authenticity_token).rendering_params
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
