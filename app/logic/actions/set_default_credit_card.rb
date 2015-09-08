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
  end

  def update_on_stripe

  end

  def save_in_db
    client.primary_card = client.credit_cards.find card_id
    @saved = client.save
  rescue ActiveRecord::RecordNotFound
    @saved = false
  end

  private

  attr_reader :client, :card_id
end
