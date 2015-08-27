class SubscribedDesignersQueryNotSubmitted

  def initialize(contest)
    @contest = contest
  end

  def designers
    result = (contest.subscribed_designers + contest.invited_designers).uniq(&:id)
    result.reject { |designer| contest.response_of(designer).try(:submitted?) }
  end

  private

  attr_reader :contest

end
