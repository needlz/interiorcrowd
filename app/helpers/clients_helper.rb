module ClientsHelper

  def profile_rows
    ['username', 'password', 'first_name', 'last_name', 'address', 'phone_number', 'billing_information', 'billing_address']
  end

  def message_name(user, comment)
    comment.role == user.role ? t('board_comments.me') : comment.role
  end

  def message_to_name(user, comment)
    unless comment.contest_note_id.nil?
      if !comment.contest_note.nil? && comment.contest_note.designer_id.nil?
        return '(' + t('board_comments.all_designer') + ')'
      end
    end

    ""
  end

  def message_body(comment)
    unless comment.text.nil?
      return comment.text
    else
      unless comment.contest_note.nil?
        comment.contest_note.text
      end
    end
  end

  def collocutor(user)
    [t('faq.menu.designer'), t('faq.menu.customer')].detect {|role| role != user.role}
  end

end
