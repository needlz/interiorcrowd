class CreateDesignerContestLookbooks < ActiveRecord::Migration
  def change
    create_table :lookbook_details do |t|
      t.integer :lookbook_id
      t.integer :document_id
      t.text :description
      t.string :url
      t.integer :doc_type
      t.timestamps
    end
  end
end
