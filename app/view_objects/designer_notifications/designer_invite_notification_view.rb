module DesignerNotifications

  class DesignerInviteNotificationView < NotificationView
    include Rails.application.routes.url_helpers

    def initialize(designer_invitation)
      super(designer_invitation)
      @designer_invitation = designer_invitation
      @contest = designer_invitation.contest
    end

    def color
      'blue'
    end

    def text
      I18n.t('designer_center.contests_preview.invite')
    end

    def href(spectator = nil)
      designer_center_contest_path(id: contest.id)
    end

    def type
      'invite'
    end

    private

    attr_reader :designer_invitation, :contest

  end

end
