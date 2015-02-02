class AddBillingAddressToClient < ActiveRecord::Migration
  def change
    add_column :clients, :billing_address, :string
    add_column :clients, :billing_state, :string
    add_column :clients, :billing_zip, :integer
    add_column :clients, :billing_city, :string
  end
end
