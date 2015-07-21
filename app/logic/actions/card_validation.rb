class CardValidation

  attr_reader :valid, :error_message, :card_token

  def initialize(card_attributes)
    @card_attributes = card_attributes
  end

  def perform
    @valid = false
    @card_token = nil
    @error_message = nil
    begin
      @card_token = Stripe::Token.create(card: card_attributes)
      @valid = true
    rescue Stripe::CardError => e
      error = e.json_body[:error]
      @error_message = error[:message]
    rescue Stripe::StripeError => e
      @error_message = e.message
    end
  end

  private

  attr_reader :card_attributes

end
