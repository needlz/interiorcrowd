class AddIndexForContestPromocodes < ActiveRecord::Migration
  def change
    add_index :contests_promocodes, [:contest_id, :promocode_id], unique: true
  end
end
