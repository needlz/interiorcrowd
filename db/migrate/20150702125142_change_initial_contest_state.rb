class ChangeInitialContestState < ActiveRecord::Migration
  def change
    change_column :contests, :status, :string, default: 'brief_pending'
  end
end
