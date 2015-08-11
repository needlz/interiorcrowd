class ClientEmailSignUp < ClientSignUp

  def client_attributes
    { plain_password: params[:client][:password],
      password: Client.encrypt(params[:client][:password]),
      password_confirmation: Client.encrypt(params[:client][:password_confirmation]),
      email: params[:client][:email]
    }
  end

end
