module ScheduledNotifications

  class Scheduler

    def self.scheduler_interval
      Jobs::TimeConditionalNotifications.interval
    end

    def self.scope; end

    def self.notification; end

    def self.perform
      scope.each do |notification_params|
        send_notification(notification_params)
      end
    end

    def self.send_notification(notification_params)
      Jobs::Mailer.schedule(notification, notification_params)
    end

  end

end
