class CreditCardsController < ApplicationController

  def create
    if current_user.credit_cards.create(create_credit_card)
      render nothing: true
    else
      render json: current_user.credit_cards.errors.last.full_messages, status: :unprocessable_entity
    end
  end

  def set_as_primary
    client_card = ClientPrimaryCard.new(current_user)
    client_card.set(new_primary_card_id)
    if client_card.saved?
      render nothing: true
    else
      render json: nil, status: :not_found
    end
  end

  private

  def new_primary_card_id
    params.require(:id)
  end

  def create_credit_card
    params.require(:credit_card).permit(:name_on_card, :ex_year, :ex_month, :zip, :number)
  end

end
