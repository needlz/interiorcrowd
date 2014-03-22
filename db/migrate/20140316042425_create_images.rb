class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :image
      t.string :image_file_name
      t.string :image_content_type
      t.string :image_file_size
      t.timestamps
    end
  end
end
