class RemoveCardNumebrs < ActiveRecord::Migration
  def change
    remove_column :credit_cards, :number if column_exists? :credit_cards, :number
  end
end
