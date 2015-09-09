class UpdateCreditCard

  attr_reader :card, :error_message

  def initialize(options)
    @client = options[:client]
    @card_attributes = options[:card_attributes]
    @card_id = options[:card_id]
  end

  def perform
    @card = client.credit_cards.find @card_id
    ActiveRecord::Base.transaction do
      update_on_stripe
      save_in_db
    end
  end

  def update_on_stripe
    stripe_customer = StripeCustomer.new(client)
    stripe_customer.update_card(@card)
  end

  def save_in_db
    @saved = @card.update_attributes!(card_attributes)
  end

  def saved?
    @saved
  end

  private

  attr_reader :client, :card_attributes

end