class AddStripeCustomerIdToUsers < ActiveRecord::Migration
  def change
    add_column :clients, :stripe_customer_id, :string
    add_column :clients, :stripe_card_status, :text, default: 'pending'
  end
end
