module DesignerNotifications

  class NotificationView
    include Rails.application.routes.url_helpers

    def self.for_notifications(user_notifications)
      user_notifications.map {|notification| for_notification(notification) }
    end

    def self.for_notification(notification)
      view_class = "DesignerNotifications::#{notification.type}View".constantize
      view_class.new(notification)
    end

    attr_reader :notification

    def initialize(notification)
      @notification = notification
    end

    def read_class
      'read' if notification.read
    end

    def path(spectator = nil)
      return href(spectator) if notification.read
      notification_path(id: notification.id)
    end

  end
end
