class Mailer < ActionMailer::Base
  layout 'mailer'
  default from: ENV['mailer_address']
  
  def user_registration(user, password)
    @user = user
    @password = password
    mail(to: user.email, subject: "Interior Crowd")
  end
  
  def designer_registration(user, password)
    @user = user
    @password = password
    mail(to: user.email, subject: "Interior Crowd")
  end
  
  def reset_password_mail(user, password)
    @user = user
    @password = password
    mail(to: user.email, subject: "Interior Crowd-Forgot Password")
  end

end
