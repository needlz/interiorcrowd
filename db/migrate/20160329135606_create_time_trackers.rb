class CreateTimeTrackers < ActiveRecord::Migration
  def change
    create_table :time_trackers do |t|
      t.integer :hours_suggested, default: 0
      t.integer :hours_actual, default: 0

      t.timestamps null: false
    end
  end
end
