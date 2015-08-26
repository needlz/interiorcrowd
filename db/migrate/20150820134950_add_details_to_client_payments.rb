class AddDetailsToClientPayments < ActiveRecord::Migration
  def change
    add_reference :client_payments, :credit_card, index: true
    add_column :client_payments, :amount_cents, :integer
    add_column :client_payments, :promotion_cents, :integer
  end
end
