class ConceptBoardCommentView < CommentView
  include ActionView::Helpers::DateHelper

  def text
    unless comment.text.nil?
      return comment.text
    else
      unless comment.contest_note.nil?
        comment.contest_note.text
      end
    end
  end

  def ago_text
    distance_of_time_in_words(Time.current,
                              comment.created_at.in_time_zone,
                              false,
                              highest_measure_only: true) +
        I18n.t('board_comments.ago')
  end

  def name
    if comment.role == spectator.role
      I18n.t('board_comments.me')
    else
      author.nil? ? '' : author.name
    end
  end

  def avatar_url
    return '/assets/profile-img.png' unless author.designer?
    PortfolioView.new(author.portfolio).personal_picture_url('/assets/profile-img.png')
  end

  def sub_name
    to_who
  end

  private

  def to_who
    return '(' + I18n.t('board_comments.all_designer') + ')' if from_client_to_everyone?
    ''
  end

  def from_client_to_everyone?
    comment.contest_note_id
  end

end
