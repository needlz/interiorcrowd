class AddImageProcessingToImages < ActiveRecord::Migration
  def change
    add_column :images, :image_processing, :boolean unless column_exists? :images, :image_processing
  end
end
