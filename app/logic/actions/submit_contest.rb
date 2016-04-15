class SubmitContest

  def initialize(contest)
    @contest = contest
    @performed = false
  end

  def paid?
    contest.paid? || manual_checkout?
  end

  def brief_completed?
    ContestValidation::Submission.new(ContestOptions.new(contest)).missing_options.blank?
  end

  def performed?
    @performed
  end

  def only_brief_pending?
    paid? && !brief_completed?
  end

  def submittable?
    contest.brief_pending? && brief_completed? && paid?
  end

  def try_perform
    if submittable?
      ActiveRecord::Base.transaction do
        contest.submit!
        contest.update_attributes(submission_started_at: Time.now)
        Jobs::Mailer.schedule(:new_project_on_the_platform, [contest.client.name, contest.project_name, Designer.active.pluck(:id)])
        Jobs::CheckIfBoardsReceived.schedule(contest.id, { run_at: Time.current + 3.days })
        Jobs::Mailer.schedule(:new_project_to_hello, [contest.id]) if contest.was_in_brief_pending_state
        @performed = true
      end
    end
  end

  private

  attr_reader :contest

  def manual_checkout?
    !Settings.automatic_payment && contest.client.reload.primary_card_id
  end

end
