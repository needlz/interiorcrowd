class UserMailer
  include MandrillMailer

  def user_registration(user, password)
    template 'user_registration'
    subject = " this is subject, ID: #{user.id} "
    set_template_values(set_user_params(user, password))
    mail to: [wrap_recipient(user.email, user.first_name, "to")], subject:subject

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

  def wrap_recipient(email, name, type)
    { email: email, name: name, type: type }
  end

end