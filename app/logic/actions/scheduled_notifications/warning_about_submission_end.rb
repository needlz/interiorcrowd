module ScheduledNotifications

  class WarningAboutSubmissionEnd < BeforeContestMilestoneEnd

    def self.period_before_milestone_end
      1.day
    end

    def self.notification
      :one_day_left_to_submit_concept_board
    end

    def self.status
      'submission'
    end

  end

end
