class AddOneTimeToPromocodes < ActiveRecord::Migration
  def change
    add_column :promocodes, :one_time, :boolean, default: true
  end
end
