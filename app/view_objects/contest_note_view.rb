class ContestNoteView
  include ActionView::Helpers::DateHelper

  def initialize(contest_note)
    @note = contest_note
  end

  def for_html
    { text: text,
      created_at: ago_text }
  end

  def text
    CGI.escapeHTML(note.text).split("\n").join("<br/>")
  end

  def ago_text
    I18n.t('time_ago', time: distance_of_time_in_words(Time.current, note.created_at.in_time_zone))
  end

  attr_reader :note

end
