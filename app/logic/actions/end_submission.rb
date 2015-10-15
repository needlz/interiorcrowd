class EndSubmission < EndMilestone

  def perform
    if contest.requests.submitted.count < 3
      Contest.transaction do
        contest.close!
        contest.update_attributes(finished_at: Time.now)
      end
      return
    end
    ActiveRecord::Base.transaction do
      contest.start_winner_selection!
      Jobs::Mailer.schedule(:please_pick_winner, [contest])
    end
  end

end
