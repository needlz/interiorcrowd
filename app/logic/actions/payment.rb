class Payment

  DEFAULT_CURRENCY = 'USD'

  attr_reader :client_payment, :error_message, :exception

  def initialize(contest)
    @contest = contest
    @client = contest.client
    @error = nil
  end

  def perform
    @client_payment = nil
    StripeCustomer.fill_client_info(client)
    customer = StripeCustomer.new(client)
    unless charge_already_performed?
      calculator = PriceCalculator.new(contest: contest)
      price = calculator.price_in_cents
      payment = contest.client_payment
      card = client.primary_card
      raise ArgumentError.new('Primary card not set') unless card

      if payment
        payment.update_attributes!(payment_status: 'pending',
                                   client_id: client.id,
                                   contest_id: contest.id,
                                   amount_cents: price,
                                   promotion_cents: calculator.promotion_in_cents,
                                   credit_card_id: card.id)
      else
        payment = ClientPayment.create!(payment_status: 'pending',
                                        client_id: client.id,
                                        contest_id: contest.id,
                                        amount_cents: price,
                                        promotion_cents: calculator.promotion_in_cents,
                                        credit_card_id: card.id)
      end
      @client_payment = payment
      begin
        amount = Money.new(price, DEFAULT_CURRENCY)
        description = "charge client with id #{ client.id }"
        charge = customer.charge(money: amount,
                                 description: description,
                                 card_id: card.stripe_id)
        payment.update_attributes!(payment_status: 'completed',
                                   stripe_charge_id: charge.id,
                                   last_error: nil)
        submit_contest = SubmitContest.new(contest.reload)
        submit_contest.try_perform
      rescue StandardError => e
        @error_message = e.message + "\n" + e.backtrace.join("\n")
        payment.update_attributes!(last_error: @error_message)
        raise
      end
    end
  end

  private

  attr_reader :contest, :client

  def charge_already_performed?
    contest.payed?
  end

end
