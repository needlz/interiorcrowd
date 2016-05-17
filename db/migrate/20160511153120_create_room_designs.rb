class CreateRoomDesigns < ActiveRecord::Migration
  def change
    create_table :room_designs do |t|
      t.string :room
      t.references :contest_request, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
