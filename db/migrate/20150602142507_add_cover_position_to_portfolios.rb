class AddCoverPositionToPortfolios < ActiveRecord::Migration
  def change
    add_column :portfolios, :cover_position, :text, default: '0% 0%'
  end
end
