class AddDesignerAndClientIdsToContestNotes < ActiveRecord::Migration
  def change
    change_table :contest_notes do |t|
      t.references :designer
      t.references :client
    end

    ContestNote.find_each do |note|
      note.update_attributes!(client_id: note.contest.client.id)
    end
  end
end
