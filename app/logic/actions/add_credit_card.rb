class AddCreditCard

  attr_reader :card

  def initialize(options)
    @client = options[:client]
    @card_attributes = options[:card_attributes]
    @set_as_primary = options[:set_as_primary]
  end

  def perform
    ActiveRecord::Base.transaction do
      register_in_stripe
      save_in_db
      if @set_as_primary
        set_primary_card = SetDefaultCreditCard.new(client: client, card_id: card.id)
        set_primary_card.perform
      end
    end
  end

  def register_in_stripe
    stripe_customer = StripeCustomer.new(client)
    @stripe_id = stripe_customer.import_card(card_attributes).id
  end

  def save_in_db
    last_4_digits = card_attributes[:number].last(4) if card_attributes[:number]
    card_attributes_to_be_saved = card_attributes.merge(last_4_digits: last_4_digits)
    card_attributes_to_be_saved.except!(:number, :cvc)
    @card = client.credit_cards.new(card_attributes_to_be_saved)
    @card.stripe_id = @stripe_id
    @saved = @card.save!
  end

  def saved?
    @saved
  end

  private

  attr_reader :client, :card_attributes

end
