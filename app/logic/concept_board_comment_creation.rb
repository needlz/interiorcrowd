class ConceptBoardCommentCreation

  def initialize(contest_request, comment_options, author)
    @contest_request = contest_request
    @comment_options = comment_options
    @author = author
  end

  def perform
    comment_attributes = comment_options.merge(user_id: author.id, role: author.role)
    ActiveRecord::Base.transaction do
      @comment = contest_request.comments.create!(comment_attributes)
      notify_designer(@comment) if author.client?
      CommentNotifier.new(contest_request, author, @comment).perform
    end
    @comment
  end

  private

  attr_reader :contest_request, :comment_options, :author

  def notify_designer(comment)
    ConceptBoardCommentNotification.create!(user_id: contest_request.designer.id,
                                            concept_board_comment_id: comment.id)
  end

end
