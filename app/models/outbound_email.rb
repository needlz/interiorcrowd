# == Schema Information
#
# Table name: outbound_emails
#
#  id                     :integer          not null, primary key
#  mailer_method          :string(255)
#  mail_args              :text
#  status                 :string(255)      default("not yet sent")
#  created_at             :datetime
#  updated_at             :datetime
#  sent_to_mail_server_at :datetime
#

class OutboundEmail < ActiveRecord::Base

end
