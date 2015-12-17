module ScheduledNotifications

  class OneSubmission < BeforeContestMilestoneEnd

    def self.period_before_milestone_end
      4.days
    end

    def self.notification
      :to_designers_one_submission_only
    end

    def self.status
      'submission'
    end

    def self.meets_conditions?(contest)
      contest.requests.submitted.count == 1
    end

  end

end
