class PromocodesController < ApplicationController

  def apply
    token = params[:code]
    render json: check_promocode(token)
  end

  private

  def check_promocode(token)
    code = Promocode.unused.find_by_token(token)
    result = { valid: code.present? }
    result.merge!(profit: code.profit) if code
    result
  end

end
