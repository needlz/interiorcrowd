class RemoveUrlFromLookbookDetails < ActiveRecord::Migration
  def up
    remove_column :lookbook_details, :url if column_exists? :lookbook_details, :url
    remove_column :lookbook_details, :doc_type if column_exists? :lookbook_details, :doc_type
  end

  def down
    add_column :lookbook_details, :url, :text
    add_column :lookbook_details, :doc_type, :integer
  end
end
