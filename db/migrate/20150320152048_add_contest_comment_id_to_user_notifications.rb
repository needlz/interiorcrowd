class AddContestCommentIdToUserNotifications < ActiveRecord::Migration
  def change
    add_column :user_notifications, :contest_comment_id, :integer
  end
end
