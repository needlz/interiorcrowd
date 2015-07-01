namespace :notifications do
  desc 'notifications dependant on future events'
  task :schedule do
    ScheduleWarningAboutWinnerSelectionEnd.perform
    ScheduleWarningAboutSubmissionEnd.perform
    ScheduleWarningAboutSubmissionEndClose.perform
  end
end
