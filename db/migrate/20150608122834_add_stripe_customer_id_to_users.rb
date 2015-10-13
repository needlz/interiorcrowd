class AddStripeCustomerIdToUsers < ActiveRecord::Migration
  def change
    add_column :clients, :stripe_customer_id, :string unless column_exists? :clients, :stripe_customer_id
    add_column :clients, :stripe_card_status, :string, default: 'pending'
  end
end
