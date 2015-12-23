class BuyGiftcards

  attr_reader :error_message, :giftcard_payment

  def initialize(options)
    @giftcard_payment_form = options[:giftcard_payment_form]
    @giftcard_payment = @giftcard_payment_form.giftcard_payment
    @on_error = options[:on_error]
  end

  def performed?
    @performed
  end

  def perform
    @performed = false
    begin
      ActiveRecord::Base.transaction do
        giftcard_payment.price_cents = price_cents
        giftcard_payment.save!
        charge
      end
    rescue StandardError => e
      @error_message = e.message
      @on_error.call(e)
      return
    end
    @performed = true
  end

  private

  def charge
    stripe_charge_id = pay.id
    giftcard_payment.update_attributes!(stripe_charge_id: stripe_charge_id)
  end

  def pay
    Stripe::Charge.create(
      amount: price_cents,
      currency: 'USD',
      source: @giftcard_payment_form.token,
      description: description
    )
  end

  def description
    "#{ giftcard_payment.quantity } giftcards for $#{ price_cents / 100.0 }"
  end

  def price_cents
    quantity = (giftcard_payment.quantity || 0)
    GiftcardPayment.price_per_item(quantity) * quantity * 100
  end

end
