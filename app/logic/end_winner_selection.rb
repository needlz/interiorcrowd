class EndWinnerSelection < EndMilestone

  def perform
    Jobs::Mailer.schedule(:remind_about_picking_winner, [contest])
  end

end
