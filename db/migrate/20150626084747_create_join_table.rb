class CreateJoinTable < ActiveRecord::Migration
  def change
    create_join_table :promocodes, :clients do |t|
      t.index [:promocode_id, :client_id]
      t.index [:client_id, :promocode_id]
    end
  end
end
