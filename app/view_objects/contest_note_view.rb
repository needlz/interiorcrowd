class ContestNoteView < CommentView
  include ActionView::Helpers::DateHelper

  def attributes
    { text: text,
      created_at: ago_text }
  end

  def text
    ERB::Util.html_escape(comment.text).split("\n").join("<br/>")
  end

  def ago_text
    I18n.t('time_ago', time: distance_of_time_in_words(Time.current, comment.created_at.in_time_zone, false, highest_measure_only: true))
  end

  def href
    return designer_center_contest_path(id: comment.contest.id) if spectator.designer?
    entries_client_center_index_path if spectator.client?
  end

  def name
    author.client? ? I18n.t('board_comments.me') : author_name
  end

end
