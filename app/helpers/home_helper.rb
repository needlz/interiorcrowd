module HomeHelper

  def faq_client_questions
    hello_link = { hello_email: mail_to(t('feedback_email')) }
    [{ get_in_touch: hello_link },
     :what_is,
     :who_are_designers,
     :style_profile,
     :packages,
     :contests,
     :how_many_designs,
     :how_to_collaborate_with_designer,
     :how_long,
     { forgot_password: hello_link }]
  end

  def faq_designer_questions
    [:what_is_beta, :how_contest_work, :how_communicate_client, :specs_of_design,
     :vendors, :can_include_work_in_portfolio]
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

end