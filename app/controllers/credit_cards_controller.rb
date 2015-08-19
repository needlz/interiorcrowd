class CreditCardsController < ApplicationController
  before_filter :set_client

  def set_as_primary
    current_user.primary_card = CreditCard.find params[:id]
    if current_user.save
      render json: nil, status: :ok
    else
      render json: current_user.errors.full_messages, status: :not_found
    end
  end

  private

  def set_designer
    @designer = Designer.find(session[:designer_id]) if check_designer
  end
end
