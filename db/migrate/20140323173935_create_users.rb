class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :password
      t.string :name_on_card
      t.integer :card_type
      t.string :address
      t.string :state
      t.integer :zip
      t.integer :card_number
      t.integer :card_ex_month
      t.integer :card_ex_year
      t.integer :card_cvc
      t.integer :status, default: 1
      t.timestamps
    end
  end
end
