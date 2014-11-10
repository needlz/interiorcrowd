class CreateContestRequests < ActiveRecord::Migration
  def change
    create_table :contest_requests do |t|
      t.integer :designer_id
      t.integer :contest_id
      t.text :designs
      t.text :feedback
      t.integer :status, default: 1
      t.timestamps
    end
  end
end
