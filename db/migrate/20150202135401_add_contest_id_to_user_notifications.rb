class AddContestIdToUserNotifications < ActiveRecord::Migration
  def change
    add_reference :user_notifications, :contest, index: true
  end
end
