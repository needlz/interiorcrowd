class AddFacebookUserIdToDesigners < ActiveRecord::Migration
  def change
    add_column :designers, :facebook_user_id, :bigint
  end
end
