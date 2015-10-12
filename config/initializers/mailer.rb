unless Rails.env.test?
  ActionMailer::Base.smtp_settings = {
      address:   'smtp.mandrillapp.com',
      port:      587,
      user_name: Settings.mandrill.email,
      password:  Settings.mandrill.api_token
  }
end
