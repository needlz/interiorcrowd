class AddReadToDesignerActivityComments < ActiveRecord::Migration
  def change
    add_column :designer_activity_comments, :read, :boolean, default: false unless column_exists? :designer_activity_comments, :read
  end
end
