module HomeHelper

  def faq_client_questions
    hello_link = { hello_email: mail_to(t('feedback_email')) }
    pictures_link = { pictures_email: mail_to(Settings.pictures_email) }
    [{ get_in_touch: hello_link },
     :what_is_interiorcrowd,
     :how_does_it_work,
     :what_is_crowdsourcing,
     :who_are_designers,
     :how_many_designers,
     :style_profile,
     :what_do_i_get,
     :i_want_two_things,
     :im_too_busy,
     :designer_can_help_me_with,
     { forgot_password: hello_link },
     { how_to_upload_additional_pictures: pictures_link }]
  end

  def faq_designer_questions
    []
  end

  def faq_item(faq_chapter, question)
    if question.kind_of?(Hash)
      question_name = question.keys[0].to_s
      answer_i18n_params = question.values[0]
    else
      question_name = question.to_s
      answer_i18n_params = {}
    end
    { question: t("faq.#{ faq_chapter }.#{ question_name }.question"),
      answer: t("faq.#{ faq_chapter }.#{ question_name }.answer", answer_i18n_params) }
  end

  def need_help_path
    return faq_path if current_user.anonymous?
    return faq_path + '#designer' if current_user.designer?
    faq_path + '#client'
  end

  def enlarge_icon_path
    '/assets/icons/enlarge.png'
  end

  def download_icon_path
    '/assets/icons/download.png'
  end

  def remove_icon_path
    '/assets/cross-white.png'
  end

end