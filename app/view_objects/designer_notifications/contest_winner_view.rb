module DesignerNotifications
  class ContestWinnerView
    include Rails.application.routes.url_helpers

    def initialize(designer_invitation, contest)
      @designer_invitation = designer_invitation
      @contest = contest
    end

    def color
      'red'
    end

    def text
      I18n.t('designer_center.contests_preview.winner', winner_name: contest.project_name)
    end

    def href
      designer_center_response_path(id: designer_invitation.contest_request)
    end

    private

    attr_reader :designer_invitation, :contest

  end
end
