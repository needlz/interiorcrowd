class AddDiscountToPromocodes < ActiveRecord::Migration
  def change
    add_monetize :promocodes, :discount
    rename_column :promocodes, :profit, :display_message
    rename_column :promocodes, :token, :promocode
  end
end
