class EndWinnerSelection < EndMilestone

  def perform
    Jobs::Mailer.schedule(:remind_about_picking_winner, [contest])
    Jobs::Mailer.schedule(:client_hasnt_picked_a_winner_to_designers, [contest])
  end

  def status
    'winner_selection'
  end

end
