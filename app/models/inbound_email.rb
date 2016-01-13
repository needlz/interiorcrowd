# == Schema Information
#
# Table name: inbound_emails
#
#  id           :integer          not null, primary key
#  json_content :text
#  processed    :boolean
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class InboundEmail < ActiveRecord::Base
end
