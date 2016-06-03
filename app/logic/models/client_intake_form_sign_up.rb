class ClientIntakeFormSignUp < ClientSignUp

  def client_attributes
    user_password = params[:client][:password]
    params[:client][:password] = Client.encrypt(user_password)
    params[:client][:plain_password] = user_password
    params[:client][:password_confirmation] = Client.encrypt(params[:client][:password_confirmation])
    params.require(:client).permit(
        :first_name, :last_name, :address, :state, :zip, :card_number, :card_ex_month,
        :card_ex_year, :card_cvc, :email, :city, :card_type, :phone_number, :billing_address,
        :billing_state, :billing_zip, :billing_city, :password, :plain_password, :password_confirmation,
        :designer_level_id, :name_on_card
    )
  end

end
