namespace :notifications do
  desc 'about one day left to select winner'
  task :one_day_left_to_select_winner do
    ScheduleWarningAboutWinnerSelectionEnd.perform
  end

  desc 'about one day left to submit'
  task :one_day_left_to_submit do
    ScheduleWarningAboutSubmissionEnd.perform
  end
end
