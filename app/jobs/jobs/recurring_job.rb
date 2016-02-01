module Jobs

  class RecurringJob

    def self.interval
      raise NotImplementedError
    end

    def self.schedule(args = {})
      Delayed::Job.enqueue(new, args)
    end

    def self.schedule_if_needed(args = {})
      schedule(args) unless DelayedJob.by_handler_like(name).exists?
    end

    def perform
      delay_next_call
    end

    private

    def delay_next_call
      self.class.schedule(run_at: Time.current + self.class.interval) unless future_jobs
    end

    def future_jobs
      DelayedJob.by_handler_like(self.class.name).where('current_timestamp < run_at').exists?
    end

  end

end
