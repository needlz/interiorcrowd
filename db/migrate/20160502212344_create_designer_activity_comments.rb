class CreateDesignerActivityComments < ActiveRecord::Migration
  def change
    create_table :designer_activity_comments do |t|
      t.text :text
      t.references :designer_activity, index: true, foreign_key: true
      t.references :author, polymorphic: true, index: true

      t.timestamps null: false
    end
  end
end
