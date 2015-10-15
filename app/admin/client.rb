ActiveAdmin.register Client do

  form do |f|
    f.inputs
    f.inputs 'Stripe details' do
      f.input :stripe_customer_id
    end
    f.actions
  end

  index do
    column :id
    column :first_name
    column :last_name
    column :email
    column :plain_password
    column :status
    column :phone_number
    column 'Billing Zip' do |client|
      client.primary_card.zip if client.primary_card.present?
    end
    column 'Billing State' do |client|
      client.primary_card.state if client.primary_card.present?
    end
    column 'Billing City' do |client|
      client.primary_card.city if client.primary_card.present?
    end
    column 'Billing Address' do |client|
      client.primary_card.address if client.primary_card.present?
    end
    column :primary_card
    column 'Credit Cards' do |client|
      client.credit_cards.map { |credit_card|
        link_to 'Credit card #' + credit_card.id.to_s, admin_credit_card_path(credit_card)
      }.join("<br />").html_safe
    end
    column :created_at
    column :email_opt_in
    actions
  end

  extend ActiveAdminExtensions::User

  extend_user

end
