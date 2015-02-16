class AddPlainPasswordToUsers < ActiveRecord::Migration
  def change
    add_column :clients, :plain_password, :string
    add_column :designers, :plain_password, :string
  end
end
