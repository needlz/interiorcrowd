class FillNotificationsForContestComments < ActiveRecord::Migration
  def up
    Contest.find_each do |contest|
      designer_ids = contest.subscribed_designers.map(&:id)

      contest.notes.by_client.each do |comment|
        designer_ids.each do |designer_id|
          notification = ContestCommentDesignerNotification.create!(contest_comment_id: comment.id,
                                                               user_id: designer_id,
                                                               created_at: comment.created_at)
          notification.update_columns(created_at: comment.created_at, updated_at: comment.updated_at)
        end
      end
    end
  end

  def down
    ContestCommentDesignerNotification.destroy_all
  end
end
