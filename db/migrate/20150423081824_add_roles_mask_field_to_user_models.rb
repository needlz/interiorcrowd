class AddRolesMaskFieldToUserModels < ActiveRecord::Migration
  def change
    add_column :clients, :roles_mask, :integer
    add_column :designers, :roles_mask, :integer
  end
end
