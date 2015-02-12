class AddColumnsToComments < ActiveRecord::Migration
  def change
    add_column :concept_board_comments, :role, :string
    add_column :concept_board_comments, :read, :boolean, default: false
  end
end
