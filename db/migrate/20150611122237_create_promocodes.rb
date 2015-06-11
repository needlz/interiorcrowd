class CreatePromocodes < ActiveRecord::Migration
  def change
    create_table :promocodes do |t|
      t.references :client, index: true
      t.text :token
      t.text :profit
    end
  end
end
