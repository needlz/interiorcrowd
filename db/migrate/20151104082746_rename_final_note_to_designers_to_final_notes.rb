class RenameFinalNoteToDesignersToFinalNotes < ActiveRecord::Migration
  def change
    rename_table :final_note_to_designers, :final_notes
  end
end
