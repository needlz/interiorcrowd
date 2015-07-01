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
      if comment.designer.nil?
        "#{ comment.contest_owner_name } (#{ I18n.t('board_comments.to_all_designer') }): #{ comment.text }"
      else
        "#{ comment.contest_owner_name } (#{ I18n.t('board_comments.to_you') }): #{ comment.text }"
      end
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
