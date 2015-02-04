class ChangeColumnsTypesContest < ActiveRecord::Migration
  def change
    change_column :contests, :space_length, :decimal, :precision => 10, :scale => 2
    change_column :contests, :space_width, :decimal, :precision => 10, :scale => 2
    change_column :contests, :space_height, :decimal, :precision => 10, :scale => 2
  end
end
