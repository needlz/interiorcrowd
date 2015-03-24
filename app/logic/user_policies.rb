module UserPolicies
  extend ActiveSupport::Concern

  def can_read_notification?(user_notification)
    designer? && user_notification.kind_of?(DesignerNotification)
  end

  def can_read_concept_board_comment?(comment)
    comment.contest_request.designer == self
  end

end
