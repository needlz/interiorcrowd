class RenameRieltorContactToRealtorContact < ActiveRecord::Migration
  def change
    rename_table :rieltor_contacts, :realtor_contacts
  end
end
