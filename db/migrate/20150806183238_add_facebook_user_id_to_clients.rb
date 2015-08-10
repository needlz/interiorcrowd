class AddFacebookUserIdToClients < ActiveRecord::Migration
  def change
    add_column :clients, :facebook_user_id, :bigint
  end
end
