class Payment

  DEFAULT_CURRENCY = 'USD'

  def initialize(contest)
    @contest = contest
    @client = contest.client
  end

  def perform
    customer = StripeCustomer.new(client)
    unless charge_already_in_queue?
      price = calculate_price_in_cents
      return if price <= 0
      payment = ClientPayment.create!(payment_status: 'pending', client_id: client.id, contest_id: contest.id)
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

  def calculate_price_in_cents
    result = contest.package.price_in_cents
    client.promocodes.each do |code|
      result =- code.discount_cents
    end
    result
  end

  def charge_already_in_queue?
    ClientPayment.where(client_id: client.id).exists?
  end

end
