class AddFiletypeToImages < ActiveRecord::Migration
  def change
    add_column :images, :file_type, :string, default: 'image'
  end
end
