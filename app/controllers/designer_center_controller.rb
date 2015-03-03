class DesignerCenterController < ApplicationController
  before_filter :set_designer

  def designer_center
    if @designer.portfolio.complete?
      return redirect_to designer_center_response_index_path if @designer.has_active_requests?
      redirect_to designer_center_contest_index_path
    else
      redirect_to edit_portfolio_path
    end
  end

  def updates
    @navigation = Navigation::DesignerCenter.new(:updates)
    notifications = @designer.user_notifications.includes(:contest)
    @notifications_view = DesignerNotifications::NotificationView.new(notifications).all
    contests_notes = ContestNote.includes(contest: [:requests]).where(contest_requests: { designer_id: @designer.id })
    comments = (@designer.comments.client + contests_notes).sort_by{ |comment| comment.updated_at }.reverse
    @comments = comments.map{ |comment| CommentView.create(comment, current_user) }
  end

  def training
    @navigation = Navigation::DesignerCenter.new(:training)
  end

  private

  def set_designer
    @designer = Designer.find(session[:designer_id]) if check_designer
  end
end
