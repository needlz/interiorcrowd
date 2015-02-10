class AddElementsToAvoidToContests < ActiveRecord::Migration
  def change
    add_column :contests, :elements_to_avoid, :text
  end
end
