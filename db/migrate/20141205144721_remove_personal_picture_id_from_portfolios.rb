class RemovePersonalPictureIdFromPortfolios < ActiveRecord::Migration
  def change
    remove_columns :portfolios, :personal_picture_id
  end
end
