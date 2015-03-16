module DesignerNotifications

  class ConceptBoardCommentView
    include Rails.application.routes.url_helpers

    def initialize(comment)
      @comment = comment
    end

    def color
      'green'
    end

    def text
      "#{ comment.author_name }: #{ comment.text }"
    end

    def href
      return edit_designer_center_response_path(id: comment.contest_request.id) if comment.author.designer?
      contest_request_path(id: comment.contest_request.id) if comment.author.client?
    end

    def type
      'comment'
    end

    private

    attr_reader :comment

  end

end

