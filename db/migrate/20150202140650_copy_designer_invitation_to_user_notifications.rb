class CopyDesignerInvitationToUserNotifications < ActiveRecord::Migration
  def change
    invitations = execute('SELECT * FROM designer_invitations')
    invitations.try(:each) do |row|
      execute("INSERT INTO user_notifications (user_id, contest_id, created_at, updated_at, user_type, type) VALUES (#{ row['designer_id'] }, #{ row['contest_id'] }, '#{ row['created_at'] }', '#{ row['updated_at'] }', 'DesignerNotification', 'DesignerInviteNotification')")
    end
  end
end
