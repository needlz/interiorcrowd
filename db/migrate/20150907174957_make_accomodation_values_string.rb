class MakeAccomodationValuesString < ActiveRecord::Migration
  def up
    change_column :contests, :accommodate_children, :string, null: true
    change_column :contests, :accommodate_pets, :string, null: true
  end

  def down
    ActiveRecord::Base.connection.execute 'ALTER TABLE contests ALTER COLUMN accommodate_children DROP DEFAULT;'
    ActiveRecord::Base.connection.execute 'ALTER TABLE contests ALTER COLUMN accommodate_pets DROP DEFAULT;'
    change_column :contests, :accommodate_children, 'boolean USING (CASE accommodate_children WHEN \'true\' THEN \'t\'::boolean ELSE \'f\'::boolean END)'
    change_column :contests, :accommodate_pets, 'boolean USING (CASE accommodate_pets WHEN \'true\' THEN \'t\'::boolean ELSE \'f\'::boolean END)'
  end
end
