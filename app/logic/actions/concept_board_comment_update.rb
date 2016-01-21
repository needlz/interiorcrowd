class ConceptBoardCommentUpdate < Action

  attr_reader :saved, :errors

  def initialize(comment, comment_options)
    @comment = comment
    @comment_options = comment_options
  end

  def perform
    ActiveRecord::Base.transaction do
      comment.update_attributes!(comment_attributes)
      attach_files
    end
    @saved = true
    @comment
  end

  private

  attr_reader :comment, :comment_options

  def comment_attributes
    comment_options.except(:attachments_ids)
  end

  def attach_files
    if comment_options[:attachments_ids]
      comment.attachments = Image.where(id: comment_options[:attachments_ids] - comment.attachment_ids)
      comment.save!
    end
  end

end
