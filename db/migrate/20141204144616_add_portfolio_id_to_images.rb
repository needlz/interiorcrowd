class AddPortfolioIdToImages < ActiveRecord::Migration
  def change
    add_reference :images, :portfolio
  end
end
