ActiveAdmin.register ClientPayment do

  controller do
    def scoped_collection
      super.includes(:client, contest: [:promocodes])
    end
  end

  index do
    id_column
    column :client
    column :contest
    column :payment_status
    column :last_error
    column(:stripe_charge_id) do |client_payment|
      link_to client_payment.stripe_charge_id, "https://dashboard.stripe.com/payments/#{ client_payment.stripe_charge_id }"
    end
    column :promocodes do |client_payment|
      contest = client_payment.contest
      contest.promocodes.map { |code| link_to(code.promocode, admin_promocode_path(code)) }.join(',').html_safe if contest
    end
    actions
  end

end
