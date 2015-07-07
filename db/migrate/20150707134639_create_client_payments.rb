class CreateClientPayments < ActiveRecord::Migration
  def change
    create_table :client_payments do |t|
      t.references :client, index: true
      t.string :payment_status, default: 'pending'
      t.text :last_error
      t.string :stripe_charge_id
    end
  end
end
