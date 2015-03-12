class AddStateToDesigners < ActiveRecord::Migration
  def change
    add_column :designers, :state, :string
  end
end
