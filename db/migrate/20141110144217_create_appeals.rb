class CreateAppeals < ActiveRecord::Migration
  def change
    create_table :appeals do |t|
      t.string :image
      t.string :first_name
      t.string :second_name
    end

    Appeal.create!( first_name: 'feminine', second_name: 'masculine', image: 'blank.png')
    Appeal.create!( first_name: 'elegant', second_name: 'eclectic', image: 'blank.png')
    Appeal.create!( first_name: 'traditional', second_name: 'modern', image: 'blank.png')
    Appeal.create!( first_name: 'conservative', second_name: 'bold', image: 'blank.png')
    Appeal.create!( first_name: 'muted', second_name: 'colorful', image: 'blank.png')
    Appeal.create!( first_name: 'timeless', second_name: 'trendy', image: 'blank.png')
    Appeal.create!( first_name: 'fancy', second_name: 'playful', image: 'blank.png')
  end
end
