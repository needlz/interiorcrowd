class DesignerCenterController < ApplicationController
  before_filter :set_designer

  def designer_center
    if @designer.portfolio.complete?
      redirect_to designer_center_updates_path
    else
      redirect_to edit_portfolio_path
    end
  end

  def updates
    @navigation = Navigation::DesignerCenter::Base.new(:updates)

    notifications = @designer.notifications
    @notifications_view = DesignerNotifications::NotificationView.for_notifications(notifications)
  end

  def training
    @navigation = Navigation::DesignerCenter::Base.new(:training)
  end

end
