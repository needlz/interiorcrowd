class CreateContestNotes < ActiveRecord::Migration
  def change
    create_table :contest_notes do |t|
      t.text :text
      t.references :contest, index: true

      t.timestamps
    end
  end
end
