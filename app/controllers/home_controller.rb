class HomeController < ApplicationController

  attr_accessor :incoming_url

  def index
    session[:return_to] = nil
    session[:login_after] = nil
    render
  end

  private

end
