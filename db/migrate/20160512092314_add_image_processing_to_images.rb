class AddImageProcessingToImages < ActiveRecord::Migration
  def change
    add_column :images, :image_processing, :boolean
  end
end
