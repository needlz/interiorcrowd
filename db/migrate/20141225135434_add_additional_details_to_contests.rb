class AddAdditionalDetailsToContests < ActiveRecord::Migration
  def change
    change_table :contests do |t|
      t.string :theme
      t.string :space
      t.string :accessories
      t.string :space_changes
      t.string :shop
      t.boolean :accommodate_children
      t.boolean :accommodate_pets
    end
  end
end
