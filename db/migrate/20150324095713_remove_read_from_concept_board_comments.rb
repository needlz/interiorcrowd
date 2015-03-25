class RemoveReadFromConceptBoardComments < ActiveRecord::Migration
  def up
    remove_column :concept_board_comments, :read
  end

  def down
    add_column :concept_board_comments, :read, :boolean, default: false
  end
end
