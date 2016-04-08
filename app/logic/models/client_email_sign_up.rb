class ClientEmailSignUp < ClientSignUp

  def client_attributes
    {
      first_name: params[:client][:name],
      plain_password: params[:client][:password],
      password: Client.encrypt(params[:client][:password]),
      password_confirmation: Client.encrypt(password_confirmation),
      email: params[:client][:email],
      phone_number: params[:client][:phone_number]
    }
  end

  private

  def password_confirmation
    params[:client][:password_confirmation] || params[:client][:password]
  end

end
