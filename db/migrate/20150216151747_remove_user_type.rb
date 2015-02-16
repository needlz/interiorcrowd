class RemoveUserType < ActiveRecord::Migration
  def up
    remove_column :user_notifications, :user_type
    execute "UPDATE user_notifications SET type = 'DesignerInviteNotification'  WHERE type = 'DesignerInvitation'"
  end

  def down
    add_column :user_notifications, :user_type, :string
  end
end
