class MailBeforeContestMilestoneEnd

  def self.scheduler_interval; end

  def self.period_before_milestone_end; end

  def self.notification; end

  def self.status; end

  def self.contests
    Contest.where(status: status, phase_end: future_range)
  end

  def self.future_range
    range_start = Time.current + period_before_milestone_end
    range_emd = range_start + scheduler_interval
    range_start..range_emd
  end

  def self.perform
    contests.each do |contest|
      Jobs::Mailer.schedule(notification, [contest])
    end
  end

end
