ActiveAdmin.register HourlyPayment do

  controller do
    def scoped_collection
      super.includes(time_tracker: [:contest])
    end
  end

  index do
    selectable_column
    id_column
    column :client
    column :payment_status
    column :last_error
    column(:stripe_charge_id) do |client_payment|
      link_to client_payment.stripe_charge_id, "https://dashboard.stripe.com/payments/#{ client_payment.stripe_charge_id }"
    end
    column :time_tracker
    column :credit_card
    column :hours_count
    column :total_price_in_cents
    actions
  end

  member_action :charge, method: :put do
    hourly_payment = HourlyPayment.find(params[:id])
    begin
      HourlyPaymentStripeCharge.perform(hourly_payment)
    rescue StandardError => e
      hourly_payment.update_attributes!(last_error: e.message)
      redirect_to({ action: :show }, error: e.message)
    end
  end

  action_item :charge, only: :show do
    link_to('Charge', charge_admin_hourly_payment_path(hourly_payment), method: :put)
  end

end
