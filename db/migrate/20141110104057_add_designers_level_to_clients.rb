class AddDesignersLevelToClients < ActiveRecord::Migration
  def change
    add_column :clients, :designer_level_id, :integer
  end
end
