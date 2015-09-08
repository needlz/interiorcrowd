class MakeAccomodationValuesString < ActiveRecord::Migration
  def up
    change_column :contests, :accommodate_children, :string, null: true
    change_column :contests, :accommodate_pets, :string, null: true
    change_column :contests, :durability, :integer, null: true
    change_column :contests, :entertaining, :integer, null: true
  end

  def down
    ActiveRecord::Base.connection.execute 'ALTER TABLE contests ALTER COLUMN accommodate_children DROP DEFAULT;'
    ActiveRecord::Base.connection.execute 'ALTER TABLE contests ALTER COLUMN accommodate_pets DROP DEFAULT;'
    ActiveRecord::Base.connection.execute 'ALTER TABLE contests ALTER COLUMN durability DROP DEFAULT;'
    ActiveRecord::Base.connection.execute 'ALTER TABLE contests ALTER COLUMN entertaining DROP DEFAULT;'
    change_column :contests,
                  :accommodate_children,
                  :boolean
    change_column :contests,
                  :accommodate_pets,
                  :boolean
  end
end
