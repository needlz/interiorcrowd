class RemoveDesignerIfFromLookbooks < ActiveRecord::Migration
  def change
    remove_column :lookbooks, :designer_id
  end
end
