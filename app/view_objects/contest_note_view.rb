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
    I18n.t('time_ago', time: distance_of_time_in_words(Time.current, comment.created_at.in_time_zone))
  end

  def href
    if spectator.kind_of?(Designer)
      designer_center_contest_path(id: comment.contest.id)
    elsif spectator.kind_of?(Client)
      entries_client_center_index_path
    end
  end

end
