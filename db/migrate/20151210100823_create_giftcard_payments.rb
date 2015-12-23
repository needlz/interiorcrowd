class CreateGiftcardPayments < ActiveRecord::Migration
  def change
    create_table :giftcard_payments do |t|
      t.string :stripe_charge_id
      t.integer :price_cents
      t.integer :amount
      t.text :email

      t.timestamps null: false
    end
  end
end
