module DesignerNotifications

  class FinalNoteDesignerNotificationView < NotificationView
    def initialize(designer_notification)
      super(designer_notification)
      @designer_notification = designer_notification
      @contest = designer_notification.contest
    end

    def color
      'green'
    end

    def text
      "#{ client_name } (#{ I18n.t('board_comments.to_you') }): #{ designer_notification.final_note_to_designer.text }"
    end

    def href(spectator = nil)
      designer_center_response_path(id: designer_notification.contest_request_id)
    end

    def type
      'win'
    end

    private

    attr_reader :designer_notification, :contest

    def client_name
      designer_notification.contest_request.contest.client.name
    end

  end

end
