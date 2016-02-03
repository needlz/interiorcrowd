class AddNotifiedClientContestNotYetLiveToContests < ActiveRecord::Migration
  def change
    add_column :contests, :notified_client_contest_not_yet_live, :boolean, default: true
    change_column :contests, :notified_client_contest_not_yet_live, :boolean, default: false
  end
end
