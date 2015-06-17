class AddTimestampsToOutboundEmails < ActiveRecord::Migration
  def change
    add_timestamps :outbound_emails
    add_column :outbound_emails, :sent_to_mail_server_at, :datetime
  end
end
