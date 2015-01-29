class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from ActionController::RoutingError, with: :render_404

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

  def set_moodboards_variables
    @contest_view = ContestView.new(@contest)
    all_requests = @contest.requests.published.includes(:designer, :lookbook)
    @requests_present = all_requests.present?
    shown_requests = all_requests.by_answer(params[:answer])
    @contest_requests = shown_requests.by_page(params[:page])
    unless @contest_requests.present?
      invitable_designers = Designer.includes(portfolio: [:personal_picture]).all
      @invitable_designer_views = invitable_designers.map { |designer| DesignerView.new(designer) }
    end
    @notes = @contest.notes.order(created_at: :desc).map { |note| ContestNoteView.new(note) }
    @reviewer_invitations = @contest.reviewer_invitations
    @reviewer_feedbacks = @contest.reviewer_feedbacks.includes(:invitation)
  end

end
