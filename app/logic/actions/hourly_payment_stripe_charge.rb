class HourlyPaymentStripeCharge < Action

  attr_reader :hourly_payment, :charge, :client, :credit_card

  def initialize(hourly_payment)
    @hourly_payment = hourly_payment
    @client = hourly_payment.client
    @credit_card = hourly_payment.credit_card
  end

  def perform
    stripe_charge =
      if hourly_payment.total_price_in_cents <= 0
        Hashie::Mash.new(id: Payment::ZERO_PRICE_PLACEHOLDER)
      else
        customer = StripeCustomer.new(client)
        amount = Money.new(hourly_payment.total_price_in_cents, ChargeHourlyPayment::DEFAULT_CURRENCY)
        description = "hourly charge for client with id #{ client.id }"
        customer.charge(money: amount,
                        description: description,
                        card_id: credit_card.stripe_id)
      end
    hourly_payment.update_attributes!(payment_status: 'completed',
                                      stripe_charge_id: stripe_charge.id,
                                      last_error: nil)
  end

end
