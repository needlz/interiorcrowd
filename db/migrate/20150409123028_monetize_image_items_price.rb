class MonetizeImageItemsPrice < ActiveRecord::Migration
  def change
    rename_table :product_items, :image_items
    add_monetize :image_items, :price, amount: { null: true, default: nil }
    ActiveRecord::Base.connection.execute('UPDATE image_items SET price_cents=price*100 WHERE price IS NOT NULL')
  end
end
