class AddActiveToPromocodes < ActiveRecord::Migration
  def change
    add_column :promocodes, :active, :boolean, default: true
    remove_column :promocodes, :client_id
  end
end
