class AddContactFieldsToGiftcardPayments < ActiveRecord::Migration
  def change
    change_table :giftcard_payments do |t|
      t.string :first_name
      t.string :last_name
      t.string :brokerage
      t.string :phone
    end

    rename_column :giftcard_payments, :amount, :quantity
  end
end
