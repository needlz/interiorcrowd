module DesignerNotifications
  class NotificationView
    def initialize(user_notifications)
      @user_notifications = user_notifications
    end

    def all
      user_notifications
        .map {|notification| "DesignerNotifications::#{notification.type}View"
        .constantize
        .new(notification, notification.contest)
      }
    end

    private

    attr_reader :user_notifications
  end
end