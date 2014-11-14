class AddContestIdToImages < ActiveRecord::Migration
  def change
    add_column :images, :contest_id, :integer unless column_exists? :images, :contest_id
    add_column :images, :kind, :string unless column_exists? :images, :kind
  end
end
