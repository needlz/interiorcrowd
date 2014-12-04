class AddDesignerToImages < ActiveRecord::Migration
  def change
    add_reference :images, :designer
  end
end
