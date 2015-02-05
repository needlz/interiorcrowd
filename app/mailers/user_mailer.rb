class UserMailer
  include MandrillMailer

  def user_registration(user, password)
    template 'user_registration'
    subject = "InteriorCrowd Registration"
    set_template_values(set_user_params(user, password))
    mail to: [wrap_recipient(user.email, user.first_name, "to")], subject:subject
  end

  def invite_to_contest(designer)
    template 'invite_to_contest'
    subject = "Invitation to contest"
    set_template_values(set_invitation_params(designer))
    mail to: [wrap_recipient(designer.email, designer.name, "to")], subject:subject
  end

  def reset_password(user, password)
    template 'interiorcrowd_password_reset'
    subject = "InteriorCrowd Password Reset"
    set_template_values(set_reset_password_params(user, password))
    mail to: [wrap_recipient(user.email, user.name, "to")], subject:subject
  end

  def sign_up_beta_autoresponder(email)
    template 'sign_up_beta_autoresponder'
    subject = "InteriorCrowd Private Beta"
    mail to: [wrap_recipient(email, '', "to")], subject:subject
  end

  def notify_about_new_subscriber(beta_subscriber)
    return unless Rails.env.production?
    template 'new_beta_subscriber'
    set_template_values(new_subscriber_params(beta_subscriber))
    mail to: [wrap_recipient('erikneeds@gmail.com', 'Erik Needham', "to")], subject: 'InteriorCrowd: new beta subscriber'
  end

  def invitation_to_leave_a_feedback(params, url)
    template 'invitation_to_leave_a_feedback'
    set_template_values(feedback_invitation_params(params, url))
    mail to: [wrap_recipient(params['email'], params['username'], "to")]
  end

  private

  def set_user_params(user, password)
    {
       name: user.name,
       email: user.email,
       password: password,
       text: I18n.t("registration.#{user.class.name.downcase}")
    }
  end

  def set_invitation_params(user)
    {
      name: user.name,
      email: user.email,
      text: I18n.t("invitation_to_content.invite")
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

end