module HomeHelper

  def faq_client_questions
    hello_link = { hello_email: mail_to(t('feedback_email')) }
    pictures_link = { pictures_email: mail_to(Settings.pictures_email) }
    additional_time_with_designer_link = { additional_time_with_designer:
                                               link_to(t('faq.captions.see_here'),
                                                       '#collapse11',
                                                       data: { collapse: true }) }
    what_does_cost_meeting_with_designer_link = { what_does_cost_meeting_with_designer:
                                                      link_to(t('faq.captions.see_here'),
                                                              '#collapse10',
                                                              data: { collapse: true }) }
    what_do_I_get_link = { what_do_I_get: link_to(t('faq.captions.what_exactly_do_I_get_quote'),
                                                  '#collapse8',
                                                  data: { collapse: true }) }
    [{ get_in_touch: hello_link },
     :what_is_interiorcrowd,
     :what_is_crowdsourcing,
     :who_are_designers,
     :how_many_designers,
     :want_to_meet_designer,
     :style_profile,
     { what_do_I_get: additional_time_with_designer_link },
     :I_want_two_things,
     :what_does_cost_meeting_with_designer,
     :additional_time_with_designer,
     { designer_can_help_me_with: what_does_cost_meeting_with_designer_link },
     :what_if_I_dont_like_the_products,
     { which_package_should_I_choose: what_do_I_get_link },
     :how_do_I_measure,
     :how_do_contests_work,
     :how_to_collaborate_with_designer,
     :how_long_everything_takes,
     { forgot_password: hello_link },
     { how_to_upload_additional_pictures: pictures_link },
     { full_money_back_guarantee: hello_link }]
  end

  def faq_designer_questions
    [:what_is_beta,
     :how_contest_work,
     :how_communicate_client,
     :specs_of_design,
     :vendors,
     :can_include_work_in_portfolio,
     :what_do_I_get_paid]
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

  def page_title
    content_for?(:title) ? content_for(:title) : 'InteriorCrowd'
  end

end