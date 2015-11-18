class ApplyPromocode

  def initialize(contest, promocode)
    @contest = contest
    @promocode = promocode
  end

  def perform
    code = Promocode.active.find_by_promocode(@promocode)
    if code
      ActiveRecord::Base.transaction do
        @contest.promocodes << code
        code.update_attributes!(active: false) if code.one_time
      end
    end
  end

end
