module DesignerNotifications
  class ContestInvitationView
    include Rails.application.routes.url_helpers

    def initialize(designer_invitation)
      @designer_invitation = designer_invitation
    end

    def color
      'blue'
    end

    def text
      I18n.t('designer_center.contests_preview.invite')
    end

    def href
      designer_center_contest_path(id: designer_invitation.contest_id)
    end

    private

    attr_reader :designer_invitation

  end
end
