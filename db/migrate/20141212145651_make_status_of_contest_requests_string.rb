class MakeStatusOfContestRequestsString < ActiveRecord::Migration
  def up
    change_column :contest_requests, :status, :string, default: 'submitted'
    execute "UPDATE contest_requests SET status='submitted'"
  end

  def down
    remove_column :contest_requests, :status
    add_column :contest_requests, :status, :integer, default: 1
  end
end
