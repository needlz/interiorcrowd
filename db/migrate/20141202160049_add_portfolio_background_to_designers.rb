class AddPortfolioBackgroundToDesigners < ActiveRecord::Migration
  def change
    add_reference :designers, :portfolio_background
  end
end
