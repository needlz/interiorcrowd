class PromocodesController < ApplicationController

  def apply
    render json: check_promocode(params[:code])
  end

  private

  def check_promocode(promocode)
    code = Promocode.active.find_by_promocode(promocode)
    result = { valid: code.present? }
    result.merge!(profit: code.display_message) if code
    result
  end

end
