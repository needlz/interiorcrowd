class CreateContestsImages < ActiveRecord::Migration
  def change
    create_table :contests_images do |t|
      t.references :contest
      t.references :image
      t.integer :kind
    end
  end
end
