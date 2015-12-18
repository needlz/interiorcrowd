module ScheduledNotifications

  class WarningAboutSubmissionEndClose < BeforeContestMilestoneEnd

    def self.period_before_milestone_end
      4.days
    end

    def self.notification
      :four_days_left_to_submit_concept_board
    end

    def self.status
      'submission'
    end

  end

end
