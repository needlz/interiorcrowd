class NotificationsController < ApplicationController

  before_filter :authenticate
  before_filter :set_notification, only: [:show]

  def show
    return raise_404 unless current_user.can_read_notification?(@notification)
    @notification.mark_as_read
    notification_view = DesignerNotifications::NotificationView.for_notification(@notification)
    redirect_to notification_view.href(current_user)
  end

  private

  def set_notification
    @notification = current_user.user_notifications.find_by_id(params[:id])
    raise_404 unless @notification
  end

end
