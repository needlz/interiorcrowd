class ImageItemPriceToText < ActiveRecord::Migration
  def up
    remove_column :image_items, :price
    add_column :image_items, :price, :text

  end

  def down

  end
end
