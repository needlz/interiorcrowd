class AddContestRequestIdToUserNotifications < ActiveRecord::Migration
  def up
    add_column :user_notifications, :contest_request_id, :integer
  end

  def down
    remove_column :user_notifications, :contest_request_id
  end
end
