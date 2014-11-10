class RenameParentToParentId < ActiveRecord::Migration
  def change
    rename_column :design_spaces, :parent, :parent_id
  end
end
