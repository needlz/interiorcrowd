class HomeController < ApplicationController
  def index
    redirect_to welcome_designer_path(session[:designer_id]) if session[:designer_id].present?
  end
end
