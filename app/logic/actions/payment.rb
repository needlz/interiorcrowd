class Payment

  DEFAULT_CURRENCY = 'USD'
  ZERO_PRICE_PLACEHOLDER = 'zero price'

  attr_reader :client_payment

  def initialize(contest)
    @contest = contest
    @client = contest.client
  end

  def perform
    StripeCustomer.fill_client_info(client)
    return if charge_already_performed?

    @credit_card = client.primary_card
    raise ArgumentError.new('Primary card not set') unless credit_card

    @calculator = PriceCalculator.new(contest: contest)
    @price = calculator.price_in_cents
    @client_payment = contest.client_payment

    initialize_payment_record
    begin
      perform_stripe_charge
      finalize_payment_record
      contest.reload
      submit_contest
    rescue StandardError => e
      client_payment.update_attributes!(last_error: e.message + "\n" + e.backtrace.join("\n"))
      raise
    end
  end

  def initialize_payment_record
    attributes = { payment_status: 'pending',
                   client_id: client.id,
                   contest_id: contest.id,
                   amount_cents: price,
                   promotion_cents: calculator.promotion_in_cents,
                   credit_card_id: credit_card.id }
    if client_payment
      client_payment.update_attributes!(attributes)
    else
      @client_payment = ClientPayment.create!(attributes)
    end
  end

  private

  attr_reader :contest, :client, :charge, :price, :calculator, :credit_card

  def charge_already_performed?
    contest.paid?
  end

  def perform_stripe_charge
    if price <= 0
      @charge = Hashie::Mash.new({ id: ZERO_PRICE_PLACEHOLDER })
    else
      customer = StripeCustomer.new(client)
      amount = Money.new(price, DEFAULT_CURRENCY)
      description = "charge client with id #{ client.id }"
      @charge = customer.charge(money: amount,
                                description: description,
                                card_id: credit_card.stripe_id)
    end
  end

  def finalize_payment_record
    client_payment.update_attributes!(payment_status: 'completed',
                                      stripe_charge_id: charge.id,
                                      last_error: nil)
  end

  def submit_contest
    return if contest.submission?
    submit_contest = SubmitContest.new(contest)
    submit_contest.try_perform
    contest.update_attributes!(was_in_brief_pending_state: !submit_contest.performed?)
  end

end
