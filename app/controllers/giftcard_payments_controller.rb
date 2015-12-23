class GiftcardPaymentsController < ApplicationController

  def new
    @giftcard_payment_form = GiftcardPaymentForm.new(GiftcardPayment.new)
    @quantity_options = (1..20).map do |quantity|
      price_dollars = GiftcardPayment.price_per_item(quantity)
      ["#{ quantity } for $#{ price_dollars * quantity } ($#{ price_dollars } per item)", quantity, { data: { price: price_dollars * quantity } }]
    end
  end

  def create
    giftcard_payment_form = GiftcardPaymentForm.new(params)
    buy_giftcards = BuyGiftcards.new(giftcard_payment_form: giftcard_payment_form,
                                     on_error: ->(e) { ErrorsLogger.log(e, session) })
    if buy_giftcards.perform
      redirect_to giftcard_payments_path(email: buy_giftcards.giftcard_payment.email)
    else
      flash[:error] = buy_giftcards.error_message
      redirect_to new_giftcard_payment_path
    end
  end

  def index
    @payment = GiftcardPayment.find_by_email(params[:email])
  end

end
