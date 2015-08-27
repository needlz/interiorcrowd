class CreateCreditCards < ActiveRecord::Migration
  def up
    create_table :credit_cards do |t|
      t.integer :client_id
      t.text :name_on_card
      t.string :card_type
      t.text :address
      t.string :state
      t.string :zip
      t.string :number
      t.text :city
      t.integer :cvc
      t.integer :ex_month
      t.integer :ex_year
      t.integer :last_4_digits
      t.string :stripe_card_status, default: 'pending'
      t.timestamps
    end

    add_column :clients, :primary_card_id, :integer

    Client.all.each do |client|
      card = CreditCard.new(
        name_on_card: client.name_on_card,
        card_type: client.card_type,
        address: client.billing_address,
        state: client.billing_state,
        zip: client.billing_zip,
        number: client.card_number,
        cvc: client.card_cvc,
        ex_month: client.card_ex_month,
        ex_year: client.card_ex_year,
        stripe_card_status: client.stripe_card_status,
        city: client.billing_city,
        last_4_digits: client.last_four_card_digits.to_i
      )
      unless card.save
        card.zip = '00000'
      end
      client.credit_cards << card
      client.update_attributes!(primary_card_id: card.id)
    end
  end

  def down
    remove_column :clients, :primary_card_id
    drop_table :credit_cards
  end
end
