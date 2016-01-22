ActiveAdmin.register GiftcardPayment do

  index do
    column :id
    column :first_name
    column :last_name
    column(:stripe_charge_id) do |giftcard_payment|
      link_to giftcard_payment.stripe_charge_id, "https://dashboard.stripe.com/payments/#{ giftcard_payment.stripe_charge_id }"
    end
    column :quantity
    column :price do |giftcard_payment|
      "$#{ giftcard_payment.price_cents / 100.0 }"
    end
    column :email
    column :phone
    column :created_at
    actions
  end

end
