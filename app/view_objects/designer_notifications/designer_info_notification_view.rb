module DesignerNotifications
  class DesignerInfoNotificationView
    include Rails.application.routes.url_helpers

    def initialize(designer_notification, contest)
      @designer_notification = designer_notification
      @contest = contest
    end

    def color
      'yellow'
    end

    def text
      I18n.t('designer_center.contests_preview.notification', contest_name: contest.project_name)
    end

    def href
      edit_designer_center_response_path(id: designer_notification.contest_request_id)
    end

    private

    attr_reader :designer_notification, :contest

  end
end