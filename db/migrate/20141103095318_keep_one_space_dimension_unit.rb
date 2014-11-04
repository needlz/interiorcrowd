class KeepOneSpaceDimensionUnit < ActiveRecord::Migration
  def change
    remove_columns :contests, :cd_space_ilength, :cd_space_iwidth, :cd_space_iheight,
                               :cd_space_flength, :cd_space_fwidth, :cd_space_fheight
    add_column :contests, :space_length, :integer, null: false, default: 0
    add_column :contests, :space_width, :integer, null: false, default: 0
    add_column :contests, :space_height, :integer, null: true
  end
end
