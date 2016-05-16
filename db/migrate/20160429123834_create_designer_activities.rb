class CreateDesignerActivities < ActiveRecord::Migration
  def change
    create_table :designer_activities do |t|
      t.datetime :start_date
      t.datetime :due_date
      t.string :task
      t.integer :hours
      t.integer :time_tracker_id

      t.timestamps null: false
    end
  end
end
