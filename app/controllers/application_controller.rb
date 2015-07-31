class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  rescue_from StandardError, with: :log_error unless Rails.env.development?

  helper_method :current_user

  before_filter :beta_redirect
  before_filter :set_return_to_link, :setup_event_tracker

  PAGE_404_PATH = 'public/404.html'

  def beta_redirect
    if (request.subdomain == 'beta')
      redirect_to subdomain: 'www', controller: controller_name, action: action_name, status: :moved_permanently
    end
  end

  def check_designer
    redirect_to designer_login_sessions_path if session[:designer_id].blank?
    session[:designer_id]
  end

  def check_client
    redirect_to client_login_sessions_path if session[:client_id].blank?
    session[:client_id]
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

  def set_return_to_link
    return if request.method != 'GET' || controller_name == 'sessions'
    session[:return_to] = request.url unless session[:return_to].present?
  end

  def log_error(exception)
    extra_data = { session: session.to_hash }
    Rollbar.error(exception, extra_data)
    return render_404 if exception.kind_of?(ActionController::RoutingError)
    raise exception
  end

  def fetch_current_user
    return Client.find(session[:client_id]) if session[:client_id]
    return Designer.find(session[:designer_id]) if session[:designer_id]
    Anonym.new
  end

  def setup_event_tracker
    @event_tracker = EventTracker.new
    @event_tracker.user = current_user
  end

end
