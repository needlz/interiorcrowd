class MonetizeImageItemsPrice < ActiveRecord::Migration
  def change
    rename_table :product_items, :image_items
    change_table :image_items do |t|
      t.money :price, amount: { null: true, default: nil }
    end
    ActiveRecord::Base.connection.execute('UPDATE image_items SET price_cents=price*100 WHERE price IS NOT NULL')
  end
end
