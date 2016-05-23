module DesignerNotifications

  class DesignerTimeTrackerNotificationView < NotificationView
    def initialize(designer_notification)
      super(designer_notification)
      @designer_notification = designer_notification
      @contest = designer_notification.contest
    end

    def color
      'yellow'
    end

    def text
      I18n.t('time_tracker.designer.notification.text', client_name: contest.client.name)
    end

    def href(spectator = nil)
      designer_center_contest_time_tracker_path(contest_id: contest.id)
    end

    def type
      'notification'
    end

    private

    attr_reader :designer_notification, :contest

  end

end
