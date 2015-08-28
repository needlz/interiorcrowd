class CreditCardsController < ApplicationController

  def create
    new_credit_card = current_user.credit_cards.new(new_credit_card_params)
    if new_credit_card.save
      card_view = CreditCardView.new(new_credit_card)
      render partial: 'contests/card_view', locals: { card: card_view }
    else
      render json: current_user.credit_cards.last.errors.full_messages, status: :unprocessable_entity
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

  def new_credit_card_params
    params.require(:credit_card).permit(:name_on_card, :address, :city, :state, :zip,
                                        :card_type, :number, :cvc, :ex_month, :ex_year)
  end

end
