class CreateBetaSubscribers < ActiveRecord::Migration
  def change
    create_table :beta_subscribers do |t|
      t.text :email
      t.string :role
      t.text :name
    end
  end
end
