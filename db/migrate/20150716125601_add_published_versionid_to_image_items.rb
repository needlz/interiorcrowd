class AddPublishedVersionidToImageItems < ActiveRecord::Migration
  def change
    add_reference :image_items, :temporary_version, index: true
  end
end
