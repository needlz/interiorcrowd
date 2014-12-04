class AddPageNameToDesigners < ActiveRecord::Migration
  def change
    add_column :designers, :portfolio_path, :string
  end
end
