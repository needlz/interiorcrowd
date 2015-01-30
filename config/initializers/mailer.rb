unless Rails.env.test?
  ActionMailer::Base.smtp_settings = {
      address:   'smtp.mandrillapp.com',
      port:      587,
      user_name: ENV['MANDRILL_EMAIL'],
      password:  ENV['MANDRILL_PASSWORD']
  }
end