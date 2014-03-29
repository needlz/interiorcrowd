class CreateDesigners < ActiveRecord::Migration
  def change
    create_table :designers do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :password
      t.string :zip
      t.string :ex_links
      t.string :ex_document_ids
      t.timestamps
    end
  end
end
