class CreateConceptBoardComments < ActiveRecord::Migration
  def change
    create_table :concept_board_comments do |t|
      t.integer :user_id
      t.text :text
      t.integer :contest_request_id

      t.timestamps
    end
  end
end
