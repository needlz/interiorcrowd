class CreatePortfolios < ActiveRecord::Migration
  def up
    create_table :portfolios do |t|
      t.references :background
      t.references :designer, null: false
      t.integer :years_of_expirience
      t.boolean :education_gifted
      t.boolean :education_school
      t.boolean :education_apprenticed
      t.string :school_name
      t.integer :degree
      t.text :awards
      t.references :personal_picture
      t.text :style_description
      t.text :about
      t.string :path
    end

    remove_columns(:designers, :years_of_expirience, :education, :school_name, :degree, :awards,
                   :personal_picture_id, :style_description, :about, :portfolio_published)
  end

  def down
    drop_table :portfolios
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
