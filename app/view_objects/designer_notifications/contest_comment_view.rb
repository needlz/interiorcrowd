module DesignerNotifications

  class ContestCommentView
    include Rails.application.routes.url_helpers

    def initialize(comment)
      @comment = comment
      @contest = comment.contest
    end

    def color
      'green'
    end

    def text
      "#{ comment.contest_owner_name }: #{ comment.text }"
    end

    def href
      designer_center_contest_path(id: contest.id)
    end

    def type
      'comment'
    end

    private

    attr_reader :comment, :contest

  end

end
