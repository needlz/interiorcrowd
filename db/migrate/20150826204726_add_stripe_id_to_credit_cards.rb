class AddStripeIdToCreditCards < ActiveRecord::Migration
  def change
    add_column :credit_cards, :stripe_id, :string unless column_exists? :credit_cards, :stripe_id
  end
end
