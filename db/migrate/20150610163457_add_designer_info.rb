class AddDesignerInfo < ActiveRecord::Migration
  def change
    add_column :designers, :address, :text
    add_column :designers, :city, :text
  end
end
