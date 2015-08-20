class CreditCardsController < ApplicationController

  def set_as_primary
    client_card = ClientPrimaryCard.new(current_user)

    render client_card.set(new_primary_card_params)
  end

  private

  def new_primary_card_params
    params.require(:id)
  end

end
