class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  rescue_from StandardError, with: :log_error unless Rails.env.development?

  helper_method :current_user

  before_filter :check_beta_area_access

  PAGE_404_PATH = 'public/404.html'

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
    render file: PAGE_404_PATH, layout: 'sign_up', status: 404
  end

  def check_contest_owner
    return unless check_client
    @client = Client.find(session[:client_id])
    raise_404 unless @contest.client == @client
  end

  def current_user
    @current_user ||= fetch_current_user
  end

  def check_beta_area_access
    return if Rails.env.staging?
    return unless beta_page?
    session[:return_to] = request.url unless session[:return_to].present?
    redirect_to sign_in_beta_path unless beta_access_granted?
  end

  def clear_creation_storage
    session[:design_brief] = nil
    session[:design_style] = nil
    session[:design_space] = nil
    session[:preview] = nil
  end

  def authenticate
    raise_404 if current_user.anonymous?
    current_user
  end

  private

  def log_error(exception)
    extra_data = {}
    extra_data[:client_id] = session[:client_id] if session[:client_id].present?
    extra_data[:designer_id] = session[:designer_id] if session[:designer_id].present?
    Rollbar.error(exception, extra_data)
    return render_404 if exception.kind_of?(ActionController::RoutingError)
    raise exception
  end

  def beta_access_granted?
    cookies.signed[:beta]
  end

  def beta_page?
    inside_beta_subdomain = (request.subdomain == 'beta')
    on_beta_sign_in_page = (controller_name == 'home' && %w(sign_in_beta create_beta_session).include?(action_name))
    inside_beta_subdomain && !on_beta_sign_in_page
  end

  def fetch_current_user
    return Client.find(session[:client_id]) if session[:client_id]
    return Designer.find(session[:designer_id]) if session[:designer_id]
    anonym = Object.new
    anonym.extend(User)
    anonym
  end

end
