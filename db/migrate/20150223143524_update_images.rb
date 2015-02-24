class UpdateImages < ActiveRecord::Migration
  def up
    remove_column :designer_levels, :image
    remove_column :appeals, :image
  end

  def down
    add_column :designer_levels, :image, :string
    add_column :appeals, :image, :string
  end
end
