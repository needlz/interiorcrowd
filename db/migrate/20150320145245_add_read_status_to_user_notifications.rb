class AddReadStatusToUserNotifications < ActiveRecord::Migration
  def change
    add_column :user_notifications, :read, :boolean, default: false
  end
end
