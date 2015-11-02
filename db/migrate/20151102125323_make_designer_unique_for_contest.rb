class MakeDesignerUniqueForContest < ActiveRecord::Migration
  def change
    add_index :contest_requests, [:contest_id, :designer_id], unique: true
  end
end
