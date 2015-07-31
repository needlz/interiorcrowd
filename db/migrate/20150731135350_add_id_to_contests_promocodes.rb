class AddIdToContestsPromocodes < ActiveRecord::Migration
  def change
    add_column :contests_promocodes, :id, :primary_key
    remove_index :contests_promocodes, column: [:contest_id, :promocode_id]
    remove_index :contests_promocodes, column: [:promocode_id, :contest_id]
  end
end
