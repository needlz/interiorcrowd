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
#  api_response           :text
#

class OutboundEmail < ActiveRecord::Base

  ransacker :by_user_name, formatter: proc { |names|
    emails = []

    names.split(' ').each do |name|
      parsed_name = name.strip
      emails += FindUserEmailsWithNameLike.new(parsed_name).perform
    end

    result = []
    emails.each do |email|
      result += OutboundEmail.where("api_response ILIKE '%#{email}%'").map(&:id)
    end

    result.present? ? result : nil
  } do |parent|
    parent.table[:id]
  end

end
