class EndSubmission

  def initialize(contest)
    @contest = contest
  end

  def perform
    return contest.close! if contest.requests.submitted.count < 3
    contest.start_winner_selection!
    Jobs::Mailer.schedule(:please_pick_winner, [contest])
  end

  private

  attr_reader :contest

end
