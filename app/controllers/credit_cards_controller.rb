class CreditCardsController < ApplicationController

  before_filter :set_client

  def create
    add_card = SetCreditCard.new(client: current_user, card_attributes: new_credit_card_params)
    begin
      add_card.perform
    rescue StandardError => e
      return render json: e.message, status: :unprocessable_entity
    end

    set_primary_card = SetDefaultCreditCard.new(client: current_user, card_id: add_card.card.id)
    begin
      set_primary_card.perform
    rescue StandardError => e
      return render json: e.message, status: :unprocessable_entity
    end

    card_view = CreditCardView.new(add_card.card)
    render partial: 'contests/card_view', locals: { card: card_view }
  end

  def set_as_primary
    set_primary_card = SetDefaultCreditCard.new(client: current_user, card_id: card_id)
    set_primary_card.perform
    if set_primary_card.saved?
      render nothing: true
    else
      render json: nil, status: :not_found
    end
  end

  def edit
    @credit_card = current_user.credit_cards.find card_id
    @shared_card_view = CreditCardView.new(nil)
    render partial: 'contests/card_form', locals: { css_class: nil,
                                                    form_method: :patch,
                                                    placeholder: '**** **** **** ' }
  rescue ActiveRecord::RecordNotFound
    render text: 'There is no credit card with such id for this client.',
           status: :not_found
  end

  def update
    update_card = SetCreditCard.new(client: current_user,
                                    card_attributes: update_credit_card_params,
                                    card_id: params[:id])
    begin
      update_card.perform
    rescue StandardError => e
      error_message = e.message
    end

    if update_card.saved?
      card_view = CreditCardView.new(update_card.card)
      render partial: 'contests/card_view', locals: { card: card_view }
    else
      render json: error_message, status: :unprocessable_entity
    end
  end

  def destroy
    delete_card = DeleteCreditCard.new(client: current_user, card_id: params[:id])
    delete_card.perform
    render nothing: true
  rescue ActiveRecord::RecordNotFound
    render text: 'There is no credit card with such id for this client.',
           status: :not_found
  end

  private

  def card_id
    params.require(:id)
  end

  def new_credit_card_params
    params.require(:credit_card).permit(:name_on_card, :address, :city, :state, :zip,
                                        :card_type, :number, :cvc, :ex_month, :ex_year)
  end

  def update_credit_card_params
    params.require(:credit_card).permit(:name_on_card, :address, :city, :state, :zip,
                                        :card_type, :ex_month, :ex_year)
  end

end
