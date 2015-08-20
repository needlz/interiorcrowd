class ClientPrimaryCard
  def initialize(user)
    @user = user
  end

  def set(new_card_params)
    @user.primary_card = CreditCard.find new_card_params
    if @user.save
      { json: nil, status: :ok }
    else
      { json: @user.errors.full_messages, status: :not_found }
    end
  end
end
