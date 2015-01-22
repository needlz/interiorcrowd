class CreatePortfolioAwards < ActiveRecord::Migration
  def change
    create_table :portfolio_awards do |t|
      t.integer :portfolio_id
      t.text :name
    end
  end
end
