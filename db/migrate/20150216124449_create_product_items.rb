class CreateProductItems < ActiveRecord::Migration
  def change
    create_table :product_items do |t|
      t.text :name
      t.references :contest_request
      t.references :image
      t.text :text
      t.decimal :price
      t.text :brand
      t.text :link
      t.string :mark
      t.timestamps
    end
  end
end
