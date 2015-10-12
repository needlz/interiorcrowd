class AddContestCreatedAtToContests < ActiveRecord::Migration
  def up
    add_column :clients, :first_contest_created_at, :datetime unless column_exists? :clients, :first_contest_created_at
    add_column :clients, :latest_contest_created_at, :datetime unless column_exists? :clients, :latest_contest_created_at
    remove_column :contests, :contest_created_at if column_exists? :contests, :contest_created_at

    Client.all.each do |client|
      first_contest = client.contests.order(:created_at).first
      last_contest = client.contests.order(:created_at).last
      if first_contest
        client.update_attributes!(first_contest_created_at: first_contest.created_at)
        client.update_attributes!(latest_contest_created_at: last_contest.created_at)
      end
    end
  end

  def down
    remove_column :clients, :first_contest_created_at, :datetime if column_exists? :clients, :first_contest_created_at
    remove_column :clients, :latest_contest_created_at, :datetime if column_exists? :clients, :latest_contest_created_at
  end
end
