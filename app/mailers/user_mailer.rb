class UserMailer < ActionMailer::Base
  include MandrillMailer
  include Rails.application.routes.url_helpers

  def client_registered(client, password)
    template 'user_registration'
    subject = I18n.t('mails.client_registration.subject')
    set_template_values(set_client_registration_params(client, password))
    mail to: [wrap_recipient(client.email, client.first_name, "to")], subject: subject
  end

  def designer_registered(designer, password)
    template 'user_registration'
    subject = I18n.t('mails.designer_registration.subject')
    set_template_values(set_designer_registration_params(designer, password))
    mail to: [wrap_recipient(designer.email, designer.first_name, "to")], subject: subject
  end

  def designer_registration_info(user)
    template 'designer_registration_info'
    set_template_values(set_designer_params(user))
    mail to: [wrap_recipient(Settings.info_email, '', "to")]
  end

  def invite_to_contest(designer, client)
    template 'invite_to_contest'
    set_template_values(set_invitation_params(client))
    mail to: [wrap_recipient(designer.email, designer.name, "to")]
  end

  def reset_password(user, password)
    template 'interiorcrowd_password_reset'
    subject = I18n.t('mails.password_reset.subject')
    set_template_values(set_reset_password_params(user, password))
    mail to: [wrap_recipient(user.email, user.name, "to")], subject:subject
  end

  def sign_up_beta_autoresponder(email)
    template 'sign_up_beta_autoresponder'
    subject = I18n.t('mails.beta_autorespond.subject')
    mail to: [wrap_recipient(email, '', "to")], subject:subject
  end

  def notify_about_new_subscriber(beta_subscriber)
    return unless Rails.env.production?
    template 'new_beta_subscriber'
    set_template_values(new_subscriber_params(beta_subscriber))
    recipients = Settings.beta_notification_emails.map do |email|
      wrap_recipient(email, 'InteriorCrowd', 'to')
    end
    mail to: recipients, subject: I18n.t('mails.beta_subscriber.subject.subject')
  end

  def invitation_to_leave_a_feedback(params, url)
    template 'invitation_to_leave_a_feedback'
    set_template_values(feedback_invitation_params(params, url))
    mail to: [wrap_recipient(params['email'], params['username'], "to")]
  end

  private

  def set_client_registration_params(user, password)
    @name = user.name
    @email = user.email
    @password = password
    @client_faq_link = faq_url(anchor: 'client')
    {
      text: render_to_string('mails/client_registration')
    }
  end

  def set_designer_registration_params(designer, password)
    @name = designer.name
    @email = designer.email
    @password = password
    {
        text: render_to_string('mails/designer_registration')
    }
  end

  def set_designer_params(designer)
    {
      name: designer.name,
      email: designer.email,
      phone: designer.phone_number || ''
    }
  end

  def set_invitation_params(client)
    {
      text: I18n.t("invitation_to_content.invite",
                   name: client.name.upcase,
                   link: "<a href=#{designer_center_index_url(host: host)}> #{I18n.t("invitation_to_content.link")}</a>")
    }
  end

  def set_reset_password_params(user, password)
    {
      name: user.name,
      email: user.email,
      password: password,
      text: I18n.t("reset_password")
    }
  end

  def wrap_recipient(email, name, type)
    { email: email, name: name, type: type }
  end

  def new_subscriber_params(beta_subscriber)
    { email: beta_subscriber.email, name: beta_subscriber.name, role: beta_subscriber.role }
  end

  def feedback_invitation_params(params, url)
    {
      name: params['username'],
      email: params['email'],
      url: url
    }
  end

  def host
    Settings.app_host || 'http://localhost:3000'
  end

end