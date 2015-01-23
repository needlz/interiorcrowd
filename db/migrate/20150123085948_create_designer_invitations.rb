class CreateDesignerInvitations < ActiveRecord::Migration
  def change
    create_table :designer_invitations do |t|
      t.integer :designer_id, null: false
      t.integer :contest_id, null: false
    end
    add_index(:designer_invitations, [:designer_id, :contest_id], unique: true)
  end
end
