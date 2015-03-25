class ContestNoteCreation

  def initialize(contest, text, current_user)
    @contest = contest
    @client_id = current_user.id if current_user.client?
    @designer_id = current_user.id if current_user.designer?
    @text = text.strip
  end

  def perform
    comment = contest.notes.create!(text: text, client_id: client_id, designer_id: designer_id)
    notify_designers(comment) if client_id
  end

  private

  attr_reader :client_id, :designer_id, :contest, :text

  def notify_designers(comment)
    subscribed_designers_ids.each do |designer_id|
      ContestCommentDesignerNotification.create!(contest_comment_id: comment.id, user_id: designer_id)
    end
  end

  def subscribed_designers_ids
    contest.subscribed_designers.map(&:id)
  end

end
