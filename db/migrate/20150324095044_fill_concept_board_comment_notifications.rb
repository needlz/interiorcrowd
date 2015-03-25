class FillConceptBoardCommentNotifications < ActiveRecord::Migration
  def up
    ContestRequest.find_each do |contest_request|
      contest_request.comments.by_client.each do |client_comment|
        ConceptBoardCommentNotification.create!(user_id: contest_request.designer_id,
                                                concept_board_comment_id: client_comment.id)
      end
    end
  end

  def down
    ConceptBoardCommentNotification.destroy_all
  end
end
