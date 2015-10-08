class AddEmailOptInToClients < ActiveRecord::Migration
  def change
    add_column :clients, :email_opt_in, :boolean, default: true unless column_exists? :clients, :email_opt_in
  end
end
