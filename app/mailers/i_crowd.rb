class ICrowd < ActionMailer::Base
  layout 'mailer'
  default from: "vstest80@gmail.com"
  
  def user_registration(user, password)
    @user = user
    @password = password
    mail(:to => user.email, :subject => "Interior Crowd")
  end
  
  def designer_registration(user, password)
    @user = user
    @password = password
    mail(:to => user.email, :subject => "Interior Crowd")
  end

end
