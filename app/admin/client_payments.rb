ActiveAdmin.register ClientPayment do

  index do
    column :id
    column :client_id
    column :contest_id
    column :payment_status
    column :last_error
    column(:stripe_charge_id) do |client_payment|
      link_to client_payment.stripe_charge_id, "https://dashboard.stripe.com/payments/#{ client_payment.stripe_charge_id }"
    end
    actions
  end

end
