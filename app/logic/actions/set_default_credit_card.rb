class SetDefaultCreditCard
  attr_reader :saved
  alias_method :saved?, :saved

  def initialize(options)
    @client = options[:client]
    @card_id = options[:card_id]
  end

  def perform
    @card = client.credit_cards.find card_id
    ActiveRecord::Base.transaction do
      update_on_stripe
      save_in_db
    end
  rescue ActiveRecord::RecordNotFound
    @saved = false
  end

  def update_on_stripe
    stripe_customer = StripeCustomer.new(client)
    stripe_customer.set_default(@card)
  rescue Stripe::StripeError => e
    @error_message = e.message
    raise e
  end

  def save_in_db
    client.primary_card = @card
    @saved = client.save
  end

  private

  attr_reader :client, :card_id
end
