class AddLastVisitByClientAtToContestRequests < ActiveRecord::Migration
  def change
    add_column :contest_requests, :last_visit_by_client_at, :timestamp
  end
end
