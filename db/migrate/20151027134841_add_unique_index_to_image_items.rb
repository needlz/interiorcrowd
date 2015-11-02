class AddUniqueIndexToImageItems < ActiveRecord::Migration

  def change
    unless index_exists?(:image_items, [:final, :phase, :temporary_version_id])
      add_index(:image_items, [:final, :phase, :temporary_version_id], unique: true)
    end
  end

end
