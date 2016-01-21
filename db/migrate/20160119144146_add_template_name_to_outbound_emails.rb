class AddTemplateNameToOutboundEmails < ActiveRecord::Migration
  def change
    add_column :outbound_emails, :template_name, :string unless column_exists? :outbound_emails, :template_name
  end
end
