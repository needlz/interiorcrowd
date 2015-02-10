class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  rescue_from ActionController::RoutingError, with: :render_404
  rescue_from StandardError, with: :log_error

  PAGE_404_PATH = 'errors/404'

  def check_designer
    redirect_to login_sessions_path if session[:designer_id].blank?
    session[:designer_id]
  end
  
  def check_client
    redirect_to client_login_sessions_path if session[:client_id].blank?
    session[:client_id]
  end

  def to_bool(value)
    ActiveRecord::ConnectionAdapters::Column.value_to_boolean(value)
  end

  def raise_404
    raise ActionController::RoutingError.new(t('page_not_found'))
  end

  def render_404
    render PAGE_404_PATH
  end

  def check_contest_owner
    return unless check_client
    @client = Client.find(session[:client_id])
    raise_404 unless @contest.client == @client
  end

  private

  def log_error(exception)
    extra_data = {}
    extra_data[:client_id] = session[:client_id] if session[:client_id].present?
    extra_data[:designer_id] = session[:designer_id] if session[:designer_id].present?
    Rollbar.error(exception, extra_data)
  end

end
