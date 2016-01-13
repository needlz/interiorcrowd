class AddEmailThreadIdToContestRequests < ActiveRecord::Migration
  def up
    add_column :contest_requests, :email_thread_id, :string

    ContestRequest.find_each do |contest_request|
      contest_request.update_attributes!(email_thread_id: ContestRequest.generate_email_thread_id)
    end

    change_column :contest_requests, :email_thread_id, :string, null: false
  end

  def down
    remove_column :contest_requests, :email_thread_id if column_exists? :contest_requests, :email_thread_id
  end
end
