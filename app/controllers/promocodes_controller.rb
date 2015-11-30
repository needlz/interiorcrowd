class PromocodesController < ApplicationController

  def apply
    render json: check_promocode(params[:code])
  end

  private

  def check_promocode(promocode)
    code = Promocode.active.find_by_promocode(promocode)
    result = { valid: code.present? }
    if code
      display_message = code.display_message
      result.merge!(display_message: display_message, discount: code.discount_cents / 100)
    end
    result
  end

end
