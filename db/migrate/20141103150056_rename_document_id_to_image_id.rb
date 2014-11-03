class RenameDocumentIdToImageId < ActiveRecord::Migration
  def change
    rename_column :lookbook_details, :document_id, :image_id
  end
end
