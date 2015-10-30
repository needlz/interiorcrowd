class AddApiResponseToOutboundEmails < ActiveRecord::Migration
  def change
    add_column :outbound_emails, :api_response, :text
  end
end
