class FixTypoInColumnNames < ActiveRecord::Migration
  def change
    rename_column :portfolios, :years_of_expirience, :years_of_experience
  end
end
