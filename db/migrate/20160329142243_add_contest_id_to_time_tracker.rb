class AddContestIdToTimeTracker < ActiveRecord::Migration
  def change
    add_column :time_trackers, :contest_id, :integer
  end
end
