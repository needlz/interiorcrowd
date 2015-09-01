class AddCreditCard

  attr_reader :card, :error_message

  def initialize(options)
    @client = options[:client]
    @card_attributes = options[:card_attributes]
  end

  def perform
    @card = client.credit_cards.new(card_attributes)
    ActiveRecord::Base.transaction do
      register_in_stripe
      save_in_db
    end
  end

  def register_in_stripe
    stripe_customer = StripeCustomer.new(client)
      @stripe_id = stripe_customer.import_card(@card).id
  rescue Stripe::StripeError => e
    @error_message = e.message
    raise e
  end

  def save_in_db
    @card.stripe_id = @stripe_id
    @saved = @card.save
    @error_message = @card.errors.full_messages if @card.errors.present?
  end

  def saved?
    @saved
  end

  private

  attr_reader :client, :card_attributes

end