 class CreateRieltorContacts < ActiveRecord::Migration
  def change
    create_table :rieltor_contacts do |t|
      t.string :first_name
      t.string :last_name
      t.string :brokerage
      t.string :email
      t.string :phone
      t.string :choice
      t.timestamps
    end
  end
end
