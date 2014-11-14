class RemoveContestImageFileds < ActiveRecord::Migration
  def change
    remove_columns :contests, :cd_style_ex_images, :cd_space_images
  end
end
