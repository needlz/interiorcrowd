class CommentView
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::DateHelper

  delegate :updated_at, :created_at, :text, :author_name, to: :comment

  def self.create(comment, spectator)
    comment_view_class = "#{ comment.class.name }View".constantize
    comment_view_class.new(comment, spectator)
  end

  def initialize(comment, spectator)
    @spectator = spectator
    @comment = comment
    @text = comment.text
    @author_name = comment.author_name
  end

  def updated_at
    comment.updated_at
  end

  def updated_at_text
    time_ago_in_words(updated_at, include_seconds: true) + I18n.t('board_comments.ago')
  end

  private

  attr_reader :comment, :spectator
end