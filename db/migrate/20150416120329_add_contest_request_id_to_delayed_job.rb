class AddContestRequestIdToDelayedJob < ActiveRecord::Migration
  def change
    add_column :delayed_jobs, :contest_request_id, :integer
  end
end
