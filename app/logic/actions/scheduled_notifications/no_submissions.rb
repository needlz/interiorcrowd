module ScheduledNotifications

  class NoSubmissions < BeforeContestMilestoneEnd

    def self.scheduler_interval
      Jobs::TimeConditionalNotifications::INTERVAL
    end

    def self.period_before_milestone_end
      4.days
    end

    def self.notification
      :to_designers_client_no_submissions
    end

    def self.status
      'submission'
    end

    def self.meets_conditions?(contest)
      contest.requests.submitted.count.zero?
    end

  end

end
