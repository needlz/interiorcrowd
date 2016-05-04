class CreateHourlyPayments < ActiveRecord::Migration
  def change
    create_table :hourly_payments do |t|
      t.integer :client_id
      t.string :payment_status
      t.text :last_error
      t.string :stripe_charge_id
      t.integer :time_tracker_id
      t.integer :credit_card_id
      t.integer :hours_count

      t.timestamps null: false
    end
  end
end
