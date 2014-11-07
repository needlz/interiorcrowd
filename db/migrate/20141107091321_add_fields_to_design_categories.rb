class AddFieldsToDesignCategories < ActiveRecord::Migration
  def up
    change_table :design_categories do |t|
      t.string :description
      t.string :before_picture
      t.string :after_picture

      t.remove :image_name
    end
  end

  def down
    change_table :design_categories do |t|
      t.remove :before_picture
      t.remove :after_picture
      t.remove :description

      t.string :image_name, default: 'null'
    end
  end
end
