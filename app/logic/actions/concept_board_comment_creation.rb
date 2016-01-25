class ConceptBoardCommentCreation < Action

  attr_reader :comment

  def initialize(contest_request, comment_options, author)
    @contest_request = contest_request
    @comment_options = comment_options
    @author = author
  end

  def perform
    ActiveRecord::Base.transaction do
      @comment = contest_request.comments.create!(comment_attributes)
      attach_files
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

  def comment_attributes
    comment_options.except(:attachments_ids).merge(user_id: author.id, role: author.role)
  end

  def attach_files
    if comment_options[:attachments_ids]
      comment_options[:attachments_ids].each do |attachment_id|
        comment.attachments << Image.find(attachment_id) if attachment_id.present?
      end
    end
  end

end
