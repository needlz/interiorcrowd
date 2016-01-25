class ConceptBoardCommentUpdate < Action

  attr_reader :saved

  def initialize(comment, comment_attributes)
    @comment = comment
    @comment_attributes = comment_attributes
  end

  def perform
    ActiveRecord::Base.transaction do
      @saved = comment.update_attributes!(comment_attributes)
    end
    @comment
  end

  private

  attr_reader :comment, :comment_attributes

end
