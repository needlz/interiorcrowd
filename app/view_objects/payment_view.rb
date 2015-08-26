class PaymentView

  attr_reader :payer_name, :payer_card, :payer_address

  def initialize(payment)
    @payment = payment
  end

  def payer_name
    @payment.client.name
  end

  def payer_card
    @payment.client.card_number
  end

  def payer_address
    @payment.client.billing_address
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
