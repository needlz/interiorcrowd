class AddLastLoginToUsers < ActiveRecord::Migration
  def change
    add_column :clients, :last_log_in_at, :timestamp
    add_column :clients, :last_log_in_ip, :string

    add_column :designers, :last_log_in_at, :timestamp
    add_column :designers, :last_log_in_ip, :string
  end
end
