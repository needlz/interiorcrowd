class GiftcardPaymentForm

  include ActiveModel::Model

  def self.giftcard_payment_attributes
    GiftcardPayment.column_names + GiftcardPayment.reflections.keys
  end

  giftcard_payment_attributes.each do |attr|
    delegate attr.to_sym, "#{ attr }=".to_sym, to: :giftcard_payment
  end

  attr_reader :giftcard_payment, :token

  def initialize(giftcard_payment_or_params)
    if giftcard_payment_or_params.kind_of?(GiftcardPayment)
      @giftcard_payment = giftcard_payment_or_params
    else
      @params = ActionController::Parameters.new(giftcard_payment_or_params)
      @giftcard_payment = GiftcardPayment.new(giftcard_payment_params)
      @token = @params[:giftcard_payment][:token]
    end
  end

  def self.model_name
    GiftcardPayment.model_name
  end

  def giftcard_payment_params
    payment_params = @params.require(:giftcard_payment)
    phone_string = payment_params[:phone].try(:join)
    payment_params.merge!(phone: phone_string)
    payment_params.permit(:first_name, :last_name, :email, :brokerage, :choice, :phone, :quantity)
  end

end
