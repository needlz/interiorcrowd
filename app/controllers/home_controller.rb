class HomeController < ApplicationController

  attr_accessor :incoming_url

  EMBEDDED_PAGES = [:designer_acquisition, :justines_story, :about_us]
  before_filter :render_blog_page, only: EMBEDDED_PAGES

  def index
    session[:return_to] = nil
    session[:login_after] = nil
    render
  end

  def designer_acquisition; end

  def justines_story; end

  def about_us; end

  private

  def render_blog_page
    url = Settings.external_urls.blog[action_name]
    render 'shared/_iframe', locals: { iframe_src: url }
  end

end
