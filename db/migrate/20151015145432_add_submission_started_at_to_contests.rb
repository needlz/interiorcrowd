class AddSubmissionStartedAtToContests < ActiveRecord::Migration
  def change
    add_column :contests, :submission_started_at, :datetime
  end
end
