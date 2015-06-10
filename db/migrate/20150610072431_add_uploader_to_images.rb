class AddUploaderToImages < ActiveRecord::Migration
  def change
    add_column :images, :uploader_role, :string
    add_column :images, :uploader_id, :integer
  end
end
