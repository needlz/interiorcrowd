class SetDefaultLastVisitByClientAt < ActiveRecord::Migration
  def change
    ContestRequest.where(last_visit_by_client_at: nil).update_all(last_visit_by_client_at: Time.current)
  end
end
