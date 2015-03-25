module UserPolicies
  extend ActiveSupport::Concern

  def can_read_notification?(user_notification)
    user_notification.recipient == self
  end

end
