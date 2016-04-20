class AddBlogCredentialsToDesigners < ActiveRecord::Migration
  def change
    add_column :designers, :blog_account_json, :text
    add_column :designers, :blog_password, :string
    add_column :designers, :blog_username, :string
  end
end
