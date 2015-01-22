class CreateExampleLinks < ActiveRecord::Migration
  def change
    create_table :example_links do |t|
      t.string :url
      t.integer :portfolio_id
    end
  end
end
