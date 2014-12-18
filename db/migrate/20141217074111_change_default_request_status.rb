class ChangeDefaultRequestStatus < ActiveRecord::Migration
  def up
    change_column :contest_requests, :status, :string, default: 'draft'
  end

  def down
    change_column :contest_requests, :status, :string, default: 'submitted'
  end
end
