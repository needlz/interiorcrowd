class AddCoverRatioToPortfolios < ActiveRecord::Migration
  def up
    remove_column :portfolios, :cover_position
    add_column :portfolios, :cover_x_percents_offset, :float
    add_column :portfolios, :cover_y_percents_offset, :float
  end

  def down
    add_column :portfolios, :cover_position, :string
    remove_column :portfolios, :cover_x_percents_offset
    remove_column :portfolios, :cover_y_percents_offset
  end
end
