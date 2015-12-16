class AddNotifiedOwnerToClients < ActiveRecord::Migration
  def change
    add_column :clients, :notified_owner, :boolean, default: true, null: false
    change_column :clients, :notified_owner, :boolean, default: false, null: false
  end
end
