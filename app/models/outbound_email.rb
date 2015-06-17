class OutboundEmail < ActiveRecord::Base

  def sent
    update_attributes!(sent_to_mail_server_at: Time.current, status: 'sent')
  end

end
