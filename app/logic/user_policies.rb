module UserPolicies
  extend ActiveSupport::Concern

  def can_read_notification?(user_notification)
    user_notification.recipient == self
  end

  def can_see_contest?(contest, cookies)
    (contest.client == self) || invited_to_review?(contest, cookies)
  end

  def invited_to_review?(contest, cookies)
    cookies[:reviewer_token].present? && contest.reviewer_invitations.find_by_url(cookies[:reviewer_token])
  end

end
