class AddPlainMessageToOutboundEmails < ActiveRecord::Migration
  def change
    add_column :outbound_emails, :plain_message, :text unless column_exists? :outbound_emails, :plain_message
  end
end
