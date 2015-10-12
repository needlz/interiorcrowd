class AddContestKeyDateFields < ActiveRecord::Migration
  def change
    add_column :contest_requests, :submitted_at, :datetime
    add_column :contest_requests, :won_at, :datetime
    add_column :contests, :finished_at, :datetime
  end
end
