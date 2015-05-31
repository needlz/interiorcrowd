module DesignerNotifications

  class ConceptBoardCommentNotificationView < NotificationView
    include Rails.application.routes.url_helpers

    def initialize(notification)
      super(notification)
      @comment = notification.concept_board_comment
    end

    def color
      'green'
    end

    def text
      "#{ comment.author_name }(" + I18n.t('board_comments.to_you') + "): #{ comment.text }"
    end

    def href(spectator = nil)
      spectator = spectator || comment.author
      return edit_designer_center_response_path(id: comment.contest_request.id) if spectator.designer?
      contest_request_path(id: comment.contest_request.id) if spectator.client?
    end

    def type
      'comment'
    end

    private

    attr_reader :comment

  end

end
