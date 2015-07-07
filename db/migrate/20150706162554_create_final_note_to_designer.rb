class CreateFinalNoteToDesigner < ActiveRecord::Migration
  def change
    create_table :final_note_to_designers do |t|
      t.text :text
      t.integer :designer_notification_id
    end
  end
end
