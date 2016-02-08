class AddLastActivityAtToClients < ActiveRecord::Migration
  def change
    add_column :clients, :last_activity_at, :datetime
  end
end
