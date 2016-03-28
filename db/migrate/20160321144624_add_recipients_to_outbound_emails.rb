class AddRecipientsToOutboundEmails < ActiveRecord::Migration
  def change
    add_column :outbound_emails, :recipients, :text unless column_exists?(:outbound_emails, :recipients)
  end
end
