class CreateDesignerInvitations < ActiveRecord::Migration
  def change
    create_table :designer_invitations do |t|
      t.integer :designer_id, null: false
      t.integer :contest_id, null: false
    end
  end
end
