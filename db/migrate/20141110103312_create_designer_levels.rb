class CreateDesignerLevels < ActiveRecord::Migration
  def change
    create_table :designer_levels do |t|
      t.integer :level
      t.string :name
      t.string :image
    end
    DesignerLevel.create!(name: 'Novice', image: 'blank.png')
    DesignerLevel.create!(name: 'Enthusiast', image: 'blank.png')
    DesignerLevel.create!(name: 'Aficionado', image: 'blank.png')
  end
end
