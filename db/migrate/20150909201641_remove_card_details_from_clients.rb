class RemoveCardDetailsFromClients < ActiveRecord::Migration
  def change
    change_table :clients do |t|
      t.remove :name_on_card, :card_type, :card_number, :card_ex_month, :card_ex_year, :card_cvc, :billing_address,
               :billing_state, :billing_zip, :billing_city, :stripe_card_status
    end
  end
end
