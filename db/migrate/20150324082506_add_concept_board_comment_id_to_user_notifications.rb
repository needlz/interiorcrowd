class AddConceptBoardCommentIdToUserNotifications < ActiveRecord::Migration
  def change
    add_column :user_notifications, :concept_board_comment_id, :integer
  end
end
