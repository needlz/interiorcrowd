class CreateLookbooks < ActiveRecord::Migration
  def change
    create_table :lookbooks do |t|
      t.integer :designer_id
      t.integer :contest_id
      t.text :feedback
      t.timestamps
    end
  end
end
