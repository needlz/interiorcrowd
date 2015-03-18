class AddDimensionsToProductItems < ActiveRecord::Migration
  def change
    add_column :product_items, :dimensions, :text
  end
end
