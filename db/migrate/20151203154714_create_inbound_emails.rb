class CreateInboundEmails < ActiveRecord::Migration
  def change
    create_table :inbound_emails do |t|
      t.text :json_content
      t.boolean :processed

      t.timestamps null: false
    end unless table_exists? :inbound_emails
  end
end
