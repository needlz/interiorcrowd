class ApplyPromocode

  def initialize(contest, promocode)
    @contest = contest
    @promocode = promocode
  end

  def perform
    code = Promocode.active.find_by_promocode(@promocode)
    @contest.promocodes << code if code
  end

end
