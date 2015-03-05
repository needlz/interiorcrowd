class RemoveDesignCetegoryPictures < ActiveRecord::Migration
  def change
    remove_column :design_categories, :before_picture
    remove_column :design_categories, :after_picture
  end
end
