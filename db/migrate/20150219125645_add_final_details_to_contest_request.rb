class AddFinalDetailsToContestRequest < ActiveRecord::Migration
  def change
    change_table :contest_requests do |t|
      t.text :final_note
      t.text :pull_together_note
    end
  end
end
