class CreditCardsController < ApplicationController

  before_filter :set_client

  def create
    add_card = AddCreditCard.new(client: current_user, card_attributes: new_credit_card_params)
    add_card.perform
    if add_card.saved?
      card_view = CreditCardView.new(add_card.card)
      render partial: 'contests/card_view', locals: { card: card_view }
    else
      render json: add_card.error_message, status: :unprocessable_entity
    end
  end

  def set_as_primary
    client_card = ClientPrimaryCard.new(current_user)
    client_card.set(card_id)
    if client_card.saved?
      render nothing: true
    else
      render json: nil, status: :not_found
    end
  end

  def edit
    @credit_card = current_user.credit_cards.find card_id
    @shared_card_view = CreditCardView.new(nil)
    render partial: 'contests/card_form', locals: { css_class: nil, form_method: :patch }
  end

  def update
    @credit_card = current_user.credit_cards.find params[:id]
    @credit_card.update_attributes!(new_credit_card_params)
    card_view = CreditCardView.new(@credit_card)
    render partial: 'contests/card_view', locals: { card: card_view }
  rescue ActiveRecord::RecordInvalid
    render text: @credit_card.errors.full_messages, status: :unprocessable_entity
  rescue ActiveRecord::RecordNotFound
    render text: 'There is no credit card with such id for this client.', status: :not_found
  end

  def destroy
    credit_card = current_user.credit_cards.find card_id
    credit_card.destroy
    render nothing: true
  rescue ActiveRecord::RecordNotFound
    render text: 'There is no credit card with such id for this client.', status: :not_found
  end

  private

  def card_id
    params.require(:id)
  end

  def new_credit_card_params
    params.require(:credit_card).permit(:name_on_card, :address, :city, :state, :zip,
                                        :card_type, :number, :cvc, :ex_month, :ex_year)
  end

end
