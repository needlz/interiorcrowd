class DesignerCenterController < ApplicationController
  before_filter :aaa ,:set_designer

  def designer_center
    if @designer.portfolio.complete?
      redirect_to updates_designer_center_index_path
    else
      redirect_to edit_portfolio_path
    end
  end

  def updates
    @navigation = Navigation::DesignerCenter.new(:updates)

    notifications = @designer.notifications
    @notifications_view = DesignerNotifications::NotificationView.for_notifications(notifications)
  end

  def training
    @navigation = Navigation::DesignerCenter.new(:training)
  end

  private

  def set_designer
    @designer = Designer.find(session[:designer_id]) if check_designer
  end
end
