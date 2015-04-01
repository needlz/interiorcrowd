class AddFinalToProductItems < ActiveRecord::Migration
  def change
    add_column :product_items, :final, :boolean, default: false
  end
end
