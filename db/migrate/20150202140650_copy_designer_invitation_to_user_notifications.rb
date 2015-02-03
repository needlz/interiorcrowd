class CopyDesignerInvitationToUserNotifications < ActiveRecord::Migration
  def up
    result = execute('SELECT * FROM designer_invitations')
    result.each do |row|
      execute("INSERT INTO user_notifications (user_id, contest_id, created_at, updated_at, user_type, type) VALUES (#{ row['designer_id'] }, #{ row['contest_id'] }, '#{ row['created_at'] }', '#{ row['updated_at'] }', 'DesignerNotification', 'DesignerInvitation')")
    end
  end

  def down
    
  end
end
