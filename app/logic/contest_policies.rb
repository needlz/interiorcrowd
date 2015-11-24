class ContestPolicies
  def initialize(contest)
    @contest = contest
  end

  def invite_designers_page_accessible?
    @contest.submission?
  end
end
