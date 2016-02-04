module Jobs

  class TimeConditionalNotifications < RecurringJob

    def self.interval
      1.hour
    end

    def perform
      ScheduledNotifications::WarningAboutWinnerSelectionEnd.perform
      ScheduledNotifications::WarningAboutSubmissionEnd.perform
      ScheduledNotifications::WarningAboutSubmissionEndClose.perform
      ScheduledNotifications::NoSubmissions.perform
      ScheduledNotifications::OneSubmission.perform
      ScheduledNotifications::DesignerWaitingFeedback.perform
      super
    end

    def queue_name
      Jobs::MAILER_QUEUE
    end

  end

end
