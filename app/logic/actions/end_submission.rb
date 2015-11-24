class EndSubmission < EndMilestone

  def perform
    close and return if contest.requests.submitted.count < 1
    ActiveRecord::Base.transaction do
      contest.start_winner_selection!
      Jobs::Mailer.schedule(:please_pick_winner, [contest])
    end
  end

  def status
    'submission'
  end

  private

  def close
    Contest.transaction do
      contest.close!
      contest.update_attributes(finished_at: Time.now)
    end
  end

end
