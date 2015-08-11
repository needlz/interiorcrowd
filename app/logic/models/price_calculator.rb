class PriceCalculator
  def initialize(price_params)
    @contest = price_params[:contest]
  end

  def price_in_cents
    result = contest.package.price_in_cents
    contest.promocodes.each do |code|
      result = result - code.discount_cents
    end
    result
  end

  attr_reader :contest

end