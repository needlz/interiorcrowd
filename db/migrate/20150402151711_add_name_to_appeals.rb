class AddNameToAppeals < ActiveRecord::Migration
  def change
    add_column :appeals, :name, :string
    remove_column :appeals, :first_name
    remove_column :appeals, :second_name
  end
end
