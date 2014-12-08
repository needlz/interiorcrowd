class MakeEducationDegreeString < ActiveRecord::Migration
  def change
    change_column :portfolios, :degree, :string
  end
end
