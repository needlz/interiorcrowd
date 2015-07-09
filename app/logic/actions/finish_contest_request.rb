class FinishContestRequest

  def initialize(contest_request)
    @contest_request = contest_request
  end

  def perform
    ActiveRecord::Base.transaction do
      contest_request.finish!
      contest_request.contest.finish!

      notify_client
    end
  end

  private

  attr_reader :contest_request

  def notify_client
    Jobs::Mailer.schedule(:designer_submitted_final_design, [contest_request])
  end

end
