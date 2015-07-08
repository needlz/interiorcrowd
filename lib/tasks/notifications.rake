namespace :notifications do
  desc 'notifications dependant on future events'
  task schedule: :environment do
    Jobs::TimeConditionalNotifications.schedule_if_needed
  end
end
