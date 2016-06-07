class DesignerActivityCommentForm

  include ActiveModel::Model

  def self.comment_attributes
    DesignerActivityComment.column_names + DesignerActivityComment.reflections.keys
  end

  comment_attributes.each do |attr|
    delegate attr.to_sym, "#{ attr }=".to_sym, to: :comment
  end

  attr_reader :comment

  def initialize(comment_or_params = nil)
    if comment_or_params && comment_or_params.kind_of?(DesignerActivityComment)
      @comment = comment_or_params
    elsif comment_or_params
      @params = ActionController::Parameters.new(comment_or_params)
    else
      @comment = DesignerActivityComment.new
    end
  end

  def self.model_name
    DesignerActivityComment.model_name
  end

  def comment_params
    @params.require(:designer_activity_comment).permit(*self.class.comment_attributes)
  end

end
