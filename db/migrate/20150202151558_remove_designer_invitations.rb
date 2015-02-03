require './db/migrate/20150123085948_create_designer_invitations.rb'

class RemoveDesignerInvitations < ActiveRecord::Migration
  def up
    drop_table :designer_invitations
  end

  def down
    CreateDesignerInvitations.new.change
  end
end
