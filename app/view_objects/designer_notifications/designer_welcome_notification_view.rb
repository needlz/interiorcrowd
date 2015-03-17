module DesignerNotifications
  class DesignerWelcomeNotificationView
    include Rails.application.routes.url_helpers

    def initialize(designer_notification)
      @designer_notification = designer_notification
    end

    def color
      'yellow'
    end

    def text
      I18n.t('designer_center.welcome_message')
    end

    def href
      training_designer_center_index_path
    end

    def type
      'notification'
    end

    private

    attr_reader :designer_notification

  end
end
