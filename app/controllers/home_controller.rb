require 'open-uri'
require 'nokogiri'

class HomeController < ApplicationController

  attr_accessor :incoming_url

  PARTS_SELECTORS = {
      head: 'head',
      body: '#content',
      header: '.rst-bottom-header'
  }

  BLOG_PAGE_CACHE_EXPIRATION = 1.second

  PAGES_WITH_IFRAME = [:designer_submission]
  EMBEDDED_PAGES = [:justines_story, :about_us]

  before_filter :set_url, only: EMBEDDED_PAGES + PAGES_WITH_IFRAME
  before_filter :render_blog_page, only: EMBEDDED_PAGES

  def index
    session[:return_to] = nil
    session[:login_after] = nil
    render
  end

  def designer_submission
    render 'shared/_iframe', locals: { iframe_src: @url }
  end

  def justines_story; end

  def about_us; end

  private

  def read_blog
    return @blog_params if @blog_params
    blog_page_file = open(@url)
    blog_page_dom = Nokogiri::HTML(blog_page_file.read)
    @blog_params = {}
    PARTS_SELECTORS.keys.each do |part|
      part_content = blog_page_dom.css(PARTS_SELECTORS[part]).first.children.to_s
      Rails.cache.write(@cache_prefix + '_' + part.to_s, part_content, expires_in: BLOG_PAGE_CACHE_EXPIRATION)
      @blog_params.merge!(part => part_content)
    end
    @blog_params
  end

  def render_blog_page
    @no_global_css = true

    @cache_prefix = action_name
    locals = {}
    PARTS_SELECTORS.keys.each do |part|
      part_content = Rails.cache.fetch(@cache_prefix + '_' + part.to_s) do
        read_blog[part]
      end
      locals.merge!(part => part_content)
    end

    render 'shared/_blog_page', locals: locals, layout: 'application'
  end

  def set_url
    @url = Settings.external_urls.blog[action_name]
  end

end
