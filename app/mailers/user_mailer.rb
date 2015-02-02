class UserMailer
  include MandrillMailer

  def user_registration(user, password)
    template 'user_registration'
    subject = "InteriorCrowd Registration"
    set_template_values(set_user_params(user, password))
    mail to: [wrap_recipient('pavlov@interlink-ua.com', user.first_name, "to")], subject:subject
  end

  def invite_to_contest(designer)
    template 'invite_to_contest'
    subject = "Invitation to contest"
    set_template_values(set_invitation_params(designer))
    mail to: [wrap_recipient('pavlov@interlink-ua.com', designer.name, "to")], subject:subject
  end

  def reset_password(user, password)
    template 'interiorcrowd_password_reset'
    subject = "InteriorCrowd Password Reset"
    set_template_values(set_reset_password_params(user, password))
    mail to: [wrap_recipient('pavlov@interlink-ua.com', user.name, "to")], subject:subject
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

end