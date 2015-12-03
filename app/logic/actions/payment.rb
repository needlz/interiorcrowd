class Payment

  DEFAULT_CURRENCY = 'USD'

  attr_reader :client_payment, :error_message, :exception

  def initialize(contest)
    @contest = contest
    @client = contest.client
    @error = nil
  end

  def perform
    StripeCustomer.fill_client_info(client)
    customer = StripeCustomer.new(client)
    unless charge_already_performed?
      calculator = PriceCalculator.new(contest: contest)
      price = calculator.price_in_cents
      @client_payment = contest.client_payment
      card = client.primary_card
      raise ArgumentError.new('Primary card not set') unless card

      if client_payment
        client_payment.update_attributes!(payment_status: 'pending',
                                   client_id: client.id,
                                   contest_id: contest.id,
                                   amount_cents: price,
                                   promotion_cents: calculator.promotion_in_cents,
                                   credit_card_id: card.id)
      else
        @client_payment = ClientPayment.create!(payment_status: 'pending',
                                        client_id: client.id,
                                        contest_id: contest.id,
                                        amount_cents: price,
                                        promotion_cents: calculator.promotion_in_cents,
                                        credit_card_id: card.id)
      end
      begin
        amount = Money.new(price, DEFAULT_CURRENCY)
        description = "charge client with id #{ client.id }"
        @charge = customer.charge(money: amount,
                                 description: description,
                                 card_id: card.stripe_id)
        update_payment
        contest.reload
        submit_contest
      rescue StandardError => e
        @error_message = e.message + "\n" + e.backtrace.join("\n")
        client_payment.update_attributes!(last_error: @error_message)
        raise
      end
    end
  end

  private

  attr_reader :contest, :client, :charge

  def charge_already_performed?
    contest.payed?
  end

  def update_payment
    client_payment.update_attributes!(payment_status: 'completed',
                                      stripe_charge_id: charge.id,
                                      last_error: nil)
  end

  def submit_contest
    submit_contest = SubmitContest.new(contest)
    submit_contest.try_perform
    contest.update_attributes!(was_in_brief_pending_state: !submit_contest.performed?)
  end

end
