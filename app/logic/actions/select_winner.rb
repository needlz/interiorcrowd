class SelectWinner < Action

  def initialize(contest_request)
    @contest_request = contest_request
  end

  def perform
    contest_request.with_lock do
      ActiveRecord::Base.transaction do
        prepare_for_next_phase
        contest_request.update_attributes(won_at: Time.now)
        contest_request.contest.winner_selected!
        create_time_tracker
        notify_designer_about_win
        notify_client
        notify_product_owner
      end
    end
  end

  private

  attr_reader :contest_request

  def notify_designer_about_win
    DesignerWinnerNotification.create(user_id: contest_request.designer_id,
                                      contest_id: contest_request.contest_id,
                                      contest_request_id: contest_request.id)
    Jobs::Mailer.schedule(:notify_designer_about_win, [contest_request.id])
  end

  def notify_client
    Jobs::Mailer.schedule(:client_has_picked_a_winner, [contest_request.id])
  end

  def notify_product_owner
    Jobs::Mailer.schedule(:notify_product_owner_about_designer_win, [contest_request.id])
  end


  def prepare_for_next_phase
    PhaseUpdater.new(contest_request).monitor_phase_change do
      contest_request.winner!
    end
  end

  def create_time_tracker
    TimeTracker.create(contest: contest_request.contest)
  end

end
