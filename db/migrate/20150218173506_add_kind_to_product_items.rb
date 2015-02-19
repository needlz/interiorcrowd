class AddKindToProductItems < ActiveRecord::Migration
  def change
    add_column :product_items, :kind, :string
    execute('UPDATE product_items SET kind=\'product_items\'')
  end
end
