class CompleteContest

  def initialize(contest)
    @contest = contest
  end

  def perform
    contest.complete!
  end

  private

  attr_reader :contest

end
