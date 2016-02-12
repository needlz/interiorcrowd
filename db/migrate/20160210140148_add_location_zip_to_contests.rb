class AddLocationZipToContests < ActiveRecord::Migration
  def change
    add_column :contests, :location_zip, :string
  end
end
