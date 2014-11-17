class AddLookbookIdToContestRequests < ActiveRecord::Migration
  def change
    add_reference :contest_requests, :lookbook
  end
end
