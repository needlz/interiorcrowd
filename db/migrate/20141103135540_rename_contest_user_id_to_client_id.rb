class RenameContestUserIdToClientId < ActiveRecord::Migration
  def change
    rename_column :contests, :user_id, :client_id
  end
end
