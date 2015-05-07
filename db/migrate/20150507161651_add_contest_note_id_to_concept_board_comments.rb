class AddContestNoteIdToConceptBoardComments < ActiveRecord::Migration
  def change
    add_column :concept_board_comments, :contest_note_id, :integer
  end
end
