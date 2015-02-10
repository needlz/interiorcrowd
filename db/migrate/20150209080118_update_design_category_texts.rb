class UpdateDesignCategoryTexts < ActiveRecord::Migration
  def change
    remove_column :design_categories, :description
    execute('UPDATE design_categories SET name=\'quick_fix\' WHERE id=1')
    execute('UPDATE design_categories SET name=\'update_my_style\' WHERE id=2')
    execute('UPDATE design_categories SET name=\'total_room_overhaul\' WHERE id=3')
  end
end
