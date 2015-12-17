module ScheduledNotifications

  class BeforeContestMilestoneEnd < Scheduler

    def self.period_before_milestone_end; end

    def self.status; end

    def self.contests
      Contest.where(status: status, phase_end: future_range)
    end

    def self.scope
      contests.select { |contest| meets_conditions?(contest) }.map(&:id)
    end

    def self.future_range
      range_start = Time.current + period_before_milestone_end
      range_end = range_start + scheduler_interval
      range_start..range_end
    end

    def self.meets_conditions?(contest)
      true
    end

  end

end
