class AddWasInBriefPendingStateToContests < ActiveRecord::Migration
  def change
    add_column :contests, :was_in_brief_pending_state, :boolean
  end
end
