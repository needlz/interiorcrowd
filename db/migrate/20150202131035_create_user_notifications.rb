class CreateUserNotifications < ActiveRecord::Migration
  def change
    create_table :user_notifications do |t|
      t.references :user, index: true
      t.string :user_type
      t.string :type
      t.timestamps
    end
  end
end
