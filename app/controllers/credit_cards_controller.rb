class CreditCardsController < ApplicationController

  def set_as_primary
    client_card = ClientPrimaryCard.new(current_user)
    client_card.set(new_primary_card_id)
    if client_card.saved?
      render json: nil, status: :ok
    else
      render json: nil, status: :not_found
    end
  end

  private

  def new_primary_card_id
    params.require(:id)
  end

end
