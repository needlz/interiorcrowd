class CreateDesignCategories < ActiveRecord::Migration
  def change
    create_table :design_categories do |t|
      t.string  :name
      t.integer :pos
      t.integer :price
      t.string :image_name, :default => 'null'
      t.integer :status, :default => 1
      t.timestamps
    end
  end
end
