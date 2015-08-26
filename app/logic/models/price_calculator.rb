class PriceCalculator
  def initialize(price_params)
    @contest = price_params[:contest]
  end

  def price_in_cents
    return @price_in_cents if @price_in_cents
    result = contest.package.price_in_cents
    @price_in_cents = result - promotion_in_cents
  end

  def promotion_in_cents
    return @promotion_in_cents if @promotion_in_cents
    @promotion_in_cents = 0
    contest.promocodes.each do |code|
      @promotion_in_cents = @promotion_in_cents + code.discount_cents
    end
    @promotion_in_cents
  end

  attr_reader :contest

end