class ChangeInitialConstestsStatus < ActiveRecord::Migration
  def up
    change_column :contests, :status, :string, default: 'incomplete'
  end

  def down
    change_column :contests, :status, :string, default: 'brief_pending'
  end
end
