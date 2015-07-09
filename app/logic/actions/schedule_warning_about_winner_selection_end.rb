class ScheduleWarningAboutWinnerSelectionEnd < MailBeforeContestMilestoneEnd

  def self.scheduler_interval
    Jobs::TimeConditionalNotifications::INTERVAL
  end

  def self.period_before_milestone_end
    1.day
  end

  def self.notification
    :one_day_left_to_choose_a_winner
  end

  def self.status
    'winner_selection'
  end

end
