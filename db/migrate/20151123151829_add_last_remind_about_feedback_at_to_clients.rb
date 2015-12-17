class AddLastRemindAboutFeedbackAtToClients < ActiveRecord::Migration
  def change
    add_column :clients, :last_remind_about_feedback_at, :timestamp
  end
end
