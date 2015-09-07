class DeleteCreditCard

  def initialize(options)
    @client = options[:client]
    @card_id = options[:card_id]
  end

  def perform
    @card = client.credit_cards.find @card_id
    ActiveRecord::Base.transaction do
      delete_on_stripe
      @card.destroy
    end
  end

  def delete_on_stripe
    stripe_customer = StripeCustomer.new(client)
    stripe_customer.delete_card(@card)
  rescue Stripe::StripeError => e
    @error_message = e.message
    raise e
  end

  private

  attr_reader :client
end
