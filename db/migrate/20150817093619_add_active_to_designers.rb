class AddActiveToDesigners < ActiveRecord::Migration
  def change
    add_column :designers, :active, :boolean, default: true
  end
end
