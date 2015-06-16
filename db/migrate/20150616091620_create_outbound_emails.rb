class CreateOutboundEmails < ActiveRecord::Migration
  def change
    create_table :outbound_emails do |t|
      t.string :mailer_method
      t.text :mail_args
      t.string :status, default: 'not yet sent'
    end
  end
end
