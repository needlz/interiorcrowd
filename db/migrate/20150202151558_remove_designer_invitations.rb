class RemoveDesignerInvitations < ActiveRecord::Migration
  def change
    drop_table :designer_invitations
  end
end
