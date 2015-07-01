class SubscribedDesignersQueryNotSubmitted

  def initialize(contest)
    @contest = contest
  end

  def designers
    result = contest.subscribed_designers
    result.reject { |designer| contest.response_of(designer).try(:submitted?) }
  end

  private

  attr_reader :contest

end
