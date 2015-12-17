class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  rescue_from StandardError, with: :handle_error unless Rails.env.development?

  helper_method :current_user

  before_filter :beta_redirect
  before_filter :setup_event_tracker
  before_filter :expire_hsts
  before_filter :on_page_visit

  add_flash_types :error

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

  def raise_404(e = nil)
    log_error(e) if e
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

  def set_client
    @client = Client.find_by_id(check_client)
  end

  def set_designer
    @designer = Designer.find_by_id(check_designer)
  end

  def log_error(exception)
    ErrorsLogger.log(exception, session.to_hash)
  end

  def new_credit_card_params
    params.require(:credit_card).permit(:name_on_card, :address, :city, :state, :zip,
                                        :card_type, :number, :cvc, :ex_month, :ex_year)
  end

  private

  def on_page_visit
    return if request.method != 'GET' || controller_name == 'sessions'
    store_return_to_link
  end

  def store_return_to_link
    session[:return_to] = request.url unless session[:return_to].present?
  end

  def handle_error(exception)
    log_error(exception)
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

  def expire_hsts
    response.headers["Strict-Transport-Security"] = 'max-age=0'
  end

end
