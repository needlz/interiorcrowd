class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  def check_designer
    redirect_to login_sessions_path if session[:designer_id].blank?
    session[:designer_id].present?
  end
  
  def check_client
    redirect_to client_login_sessions_path if session[:client_id].blank?
    session[:client_id].present?
  end
end
