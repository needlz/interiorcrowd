class ImageItemPriceToText < ActiveRecord::Migration
  def up
    remove_column :image_items, :price
    add_column :image_items, :price, :text

    ActiveRecord::Base.connection.execute('UPDATE image_items SET price=CONCAT(\'$\', price_cents::float / 100) WHERE price_cents IS NOT NULL')
  end

  def down

  end
end
