class SubmitContest

  def initialize(contest)
    @contest = contest
  end

  def perform
    contest.submit!
    Jobs::CheckIfBoardsReceived.schedule(contest.id, { run_at: Time.current + 3.days })
  end

  private

  attr_reader :contest

end
