class PaymentView

  attr_reader :payer_name, :payer_card, :payer_address

  delegate :name_on_card, :card_number, :full_address, to: :payer_card

  def initialize(payment)
    @payment = payment
    @payer_card = CreditCardView.new(payment.credit_card)
  end

  def order_total
    PackageView.new(@payment.contest.package).price
  end

  def promotion
    @payment.promotion_cents / 100.00
  end

  def total_price
    @payment.amount_cents / 100.00
  end

end
