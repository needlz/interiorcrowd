class ContestNoteView < CommentView
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::TextHelper

  def attributes
    { text: text,
      created_at: ago_text }
  end

  def text
    auto_link(simple_format(comment.text), html: { target: '_blank' }).html_safe
  end

  def ago_text
    I18n.t('time_ago', time: distance_of_time_in_words(Time.current,
                                                       comment.created_at.in_time_zone,
                                                       false,
                                                       highest_measure_only: true))
  end

  def href
    return designer_center_contest_path(id: comment.contest.id) if spectator.designer?
    client_center_entries_path if spectator.client?
  end

  def name
    author.client? ? I18n.t('board_comments.me') : author_name
  end

end
