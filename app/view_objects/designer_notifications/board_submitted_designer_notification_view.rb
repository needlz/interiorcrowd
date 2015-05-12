module DesignerNotifications
  class BoardSubmittedDesignerNotificationView < NotificationView
    include Rails.application.routes.url_helpers

    def initialize(designer_notification)
      super(designer_notification)
      @designer_notification = designer_notification
    end

    def color
      'yellow'
    end

    def text
      I18n.t('designer_center.notifications.successfully_submitted', contest_name: designer_notification.contest.project_name)
    end

    def href(spectator = nil)
      designer_center_response_path(id: designer_notification.contest_request_id)
    end

    def type
      'notification'
    end

    private

    attr_reader :designer_notification

  end
end

