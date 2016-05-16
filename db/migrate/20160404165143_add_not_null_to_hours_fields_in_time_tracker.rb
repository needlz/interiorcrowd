class AddNotNullToHoursFieldsInTimeTracker < ActiveRecord::Migration
  def change
    change_column :time_trackers, :hours_suggested, :integer, null: false
    change_column :time_trackers, :hours_actual, :integer, null: false
  end
end
