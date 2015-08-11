class Payment

  DEFAULT_CURRENCY = 'USD'

  attr_reader :client_payment

  def initialize(contest)
    @contest = contest
    @client = contest.client
  end

  def perform
    @client_payment = nil
    customer = StripeCustomer.new(client)
    unless charge_already_performed?
      calculator = PriceCalculator.new(contest: contest)
      price = calculator.price_in_cents
      payment = ClientPayment.create!(payment_status: 'pending', client_id: client.id, contest_id: contest.id)
      @client_payment = payment
      begin
        amount = Money.new(price, DEFAULT_CURRENCY)
        description = "charge client with id #{ client.id }"
        charge = customer.charge(money: amount, description: description)
        payment.update_attributes!(payment_status: 'completed', stripe_charge_id: charge.id)
      rescue StandardError => e
        payment.update_attributes!(last_error: e.message + "\n" + e.backtrace.join("\n"))
      end
    end
  end

  private

  attr_reader :contest, :client

  def charge_already_performed?
    ClientPayment.where(contest_id: contest.id).exists?
  end

end
