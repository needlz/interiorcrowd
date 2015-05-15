module DesignerNotifications

  class ContestCommentDesignerNotificationView < NotificationView
    include Rails.application.routes.url_helpers

    def initialize(notification)
      super(notification)
      @comment = notification.contest_comment
      @contest = comment.contest
    end

    def color
      'green'
    end

    def text
      "#{ comment.contest_owner_name }: #{ comment.text }"
    end

    def href(spectator = nil)
      contest_request = contest.response_of(spectator)
      if contest_request
        designer_center_response_path(id: contest.response_of(spectator).id)
      else
        designer_center_contest_path(id: contest.id)
      end
    end

    def type
      'comment'
    end

    private

    attr_reader :comment, :contest

  end

end
