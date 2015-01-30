unless Rails.env.test?
  ActionMailer::Base.smtp_settings = {
      address:   'smtp.mandrillapp.com',
      port:      587,
      user_name: 'erikneeds@gmail.com',
      password:  'icrowd1icrowd'
  }
end