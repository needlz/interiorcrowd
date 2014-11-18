class AddAnswerToContestRequests < ActiveRecord::Migration
  def change
    add_column :contest_requests, :answer, :string
  end
end
