class BlogController < ApplicationController

  PAGES_WITH_IFRAME = [:designer_submission]
  EMBEDDED_PAGES = [:justines_story, :about_us]

  before_filter :set_url, only: EMBEDDED_PAGES + PAGES_WITH_IFRAME
  before_filter :render_blog_page, only: EMBEDDED_PAGES

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
    begin
      get_response = open(@url).read
    rescue OpenURI::HTTPError
      return raise_404
    else
      render_blog_page(get_response)
    end
  end

  def render_post_response
    post_response = Net::HTTP.post_form(@url, params)
    render_blog_page(post_response.body)
  end

  def render_blog_page(content)
    locals = BlogPageProxy.new(content).rendering_params
    render 'shared/_blog_page', locals: locals, layout: 'application'
  end

  def set_url
    @url = Settings.external_urls.blog[action_name]
  end

end
