module Jobs

  class TimeConditionalNotifications

    INTERVAL = 1.hour

    def self.schedule(args = {})
      Delayed::Job.enqueue(new, args)
    end

    def self.schedule_if_needed(args = {})
      schedule(args) unless DelayedJob.by_handler_like(name).exists?
    end

    def perform
      ScheduleWarningAboutWinnerSelectionEnd.perform
      ScheduleWarningAboutSubmissionEnd.perform
      ScheduleWarningAboutSubmissionEndClose.perform
      delay_next_call
    end

    def queue_name
      Jobs::MAILER_QUEUE
    end

    private

    def delay_next_call
      TimeConditionalNotifications.schedule(run_at: Time.current + INTERVAL) unless future_jobs
    end

    def future_jobs
      DelayedJob.by_handler_like(TimeConditionalNotifications.name).where('current_timestamp < run_at').exists?
    end

  end

end
