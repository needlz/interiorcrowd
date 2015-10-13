class AddCoverPositionToPortfolios < ActiveRecord::Migration
  def change
    add_column :portfolios, :cover_position, :text
  end
end
