class AddPortfolioAttributesToDesigners < ActiveRecord::Migration
  def change
    add_column :designers, :years_of_expirience, :integer
    add_column :designers, :education, :string
    add_column :designers, :school_name, :string
    add_column :designers, :degree, :integer
    add_column :designers, :awards, :text
    add_reference :designers, :personal_picture
    add_column :designers, :style_description, :text
    add_column :designers, :about, :text
    add_column :designers, :portfolio_published, :boolean, default: false, null: false
  end
end
