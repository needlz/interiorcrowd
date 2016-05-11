class HomeController < ApplicationController

  attr_accessor :incoming_url

  def index
    @client = Client.new
    session[:return_to] = nil
    session[:login_after] = nil
    @main_navigation_items_prepend = [MenuBuilder::MenuItem.new(I18n.t('header.commercial'), Settings.commercial_link)]
    @dont_include_application_css = true
    render
  end

  def designer_submission; end

end
