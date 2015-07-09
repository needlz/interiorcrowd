class EndSubmission < EndMilestone

  def perform
    return contest.close! if contest.requests.submitted.count < 3
    ActiveRecord::Base.transaction do
      contest.start_winner_selection!
      Jobs::Mailer.schedule(:please_pick_winner, [contest])
    end
  end

end
