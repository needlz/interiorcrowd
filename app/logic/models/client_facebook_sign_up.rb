class ClientFacebookSignUp < ClientSignUp

  def client_attributes
    user_password = TokenGenerator.generate
    password = Client.encrypt(user_password)
    plain_password = user_password

    fb_user = Koala::Facebook::API.new(params[:token])
    fb_user_info = fb_user.api('me', { fields: ['id', 'name', 'email', 'first_name', 'last_name' ]})

    { first_name: fb_user_info['first_name'],
      last_name: fb_user_info['last_name'],
      email: fb_user_info['email'],
      password: password,
      password_confirmation: password,
      plain_password: plain_password,
      facebook_user_id: fb_user_info['id'] }
  end

end
