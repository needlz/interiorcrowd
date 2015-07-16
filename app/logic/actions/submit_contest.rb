class SubmitContest

  def initialize(contest)
    @contest = contest
    @performed = false
  end

  def payed?
    true
  end

  def brief_completed?
    contest.space_images.exists?
  end

  def performed?
    @performed
  end

  def only_brief_pending?
    payed? && !brief_completed?
  end

  def try_perform
    if contest.brief_pending? && brief_completed? && payed?
      contest.submit!
      Jobs::CheckIfBoardsReceived.schedule(contest.id, { run_at: Time.current + 3.days })
      @performed = true
    end
  end

  private

  attr_reader :contest

end
