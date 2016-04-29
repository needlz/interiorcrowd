class CreateTimeTrackerForAlreadyExistingContest < ActiveRecord::Migration
  def change
    Contest.where("status ILIKE(?)", '%fulfillment%').each do |contest|
      TimeTracker.create(contest_id: contest.id) unless contest.time_tracker
    end
  end
end
