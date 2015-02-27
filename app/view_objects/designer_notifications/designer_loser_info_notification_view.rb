module DesignerNotifications
  class DesignerLoserInfoNotificationView < DesignerInfoNotificationView
  include Rails.application.routes.url_helpers

    def initialize(designer_notification, contest)
      super(designer_notification, contest)
    end

    def text
      I18n.t('designer_center.contests_preview.loser_notification', contest_name: contest.project_name)
    end

    def href
      designer_center_response_path(id: designer_notification.contest_request_id)
    end

    private

    attr_reader :designer_notification, :contest

  end
end
