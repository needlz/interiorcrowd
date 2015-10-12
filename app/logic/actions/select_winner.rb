class SelectWinner

  def initialize(contest_request)
    @contest_request = contest_request
  end

  def perform
    PhaseUpdater.new(contest_request).monitor_phase_change do
      contest_request.winner!
    end
    contest_request.update_attributes(won_at: Time.now)
    contest_request.contest.winner_selected!
    notify_designer_about_win
    notify_client
  end

  private

  attr_reader :contest_request

  def notify_designer_about_win
    DesignerWinnerNotification.create(user_id: contest_request.designer_id,
                                      contest_id: contest_request.contest_id,
                                      contest_request_id: contest_request.id)
    Jobs::Mailer.schedule(:notify_designer_about_win, [contest_request])
  end

  def notify_client
    Jobs::Mailer.schedule(:client_has_picked_a_winner, [contest_request])
  end

end
