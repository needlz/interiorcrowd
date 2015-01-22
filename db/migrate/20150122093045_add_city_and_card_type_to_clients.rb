class AddCityAndCardTypeToClients < ActiveRecord::Migration
  def change
    add_column :clients, :city, :string
    change_column :clients, :card_type, :string
  end
end
