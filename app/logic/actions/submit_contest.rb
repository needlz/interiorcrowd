class SubmitContest

  def initialize(contest)
    @contest = contest
    @performed = false
  end

  def payed?
    contest.payed? || manual_checkout?
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

  def submittable?
    contest.brief_pending? && brief_completed? && payed?
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
    !Settings.payment_enabled && contest.client.reload.primary_card_id
  end

end
