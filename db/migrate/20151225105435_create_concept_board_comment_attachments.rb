class CreateConceptBoardCommentAttachments < ActiveRecord::Migration
  def change
    create_table :concept_board_comment_attachments do |t|
      t.integer :comment_id, foreign_key: true
      t.integer :attachment_id, foreign_key: true

      t.timestamps null: false

      t.index [:comment_id, :attachment_id], name: 'comments_and_attachments', unique: true
    end
  end
end
