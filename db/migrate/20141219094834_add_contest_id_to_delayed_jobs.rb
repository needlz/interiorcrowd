class AddContestIdToDelayedJobs < ActiveRecord::Migration
  def change
    add_column :delayed_jobs, :contest_id, :integer
  end
end
