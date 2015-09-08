class SetCreditCard

  attr_reader :card, :error_message

  def initialize(options)
    @client = options[:client]
    @card_attributes = options[:card_attributes]
    @id = options[:id]
  end

  def perform
    ActiveRecord::Base.transaction do
      register_in_stripe
      save_in_db
    end
  end

  def register_in_stripe
    stripe_customer = StripeCustomer.new(client)
    @stripe_id = stripe_customer.import_card(card_attributes).id
  rescue Stripe::StripeError => e
    @error_message = e.message
    raise e
  end

  def save_in_db
    @card = client.credit_cards.find_or_initialize_by(id: @id)
    last_4_digits = card_attributes[:number].last(4) if card_attributes[:number]
    card_attributes_to_be_saved = card_attributes.merge(last_4_digits: last_4_digits)
    card_attributes_to_be_saved.except!(:number)
    @card.attributes = card_attributes_to_be_saved
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