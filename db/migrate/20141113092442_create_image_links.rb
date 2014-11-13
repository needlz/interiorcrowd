class CreateImageLinks < ActiveRecord::Migration
  def change
    create_table :image_links do |t|
      t.references :contest
      t.string :url, limit: nil
    end
  end
end
