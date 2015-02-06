class AddEntertainingDurabilityToContests < ActiveRecord::Migration
  def change
    add_column :contests, :entertaining, :integer
    add_column :contests, :durability, :integer
  end
end
