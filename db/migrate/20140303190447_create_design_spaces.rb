class CreateDesignSpaces < ActiveRecord::Migration
  def change
    create_table :design_spaces do |t|
      t.string :name
      t.integer :pos
      t.integer :parent
      t.integer :status, default: 1
      t.timestamps
    end
  end
end
