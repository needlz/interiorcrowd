class ChangeColumnsRestriction < ActiveRecord::Migration
  def change
    change_column_null(:contests, :space_length, true)
    change_column_null(:contests, :space_width, true)
  end
end
