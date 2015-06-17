require 'rails_helper'

RSpec.describe OutboundEmail do

  let(:email) { Fabricate(:outbound_email) }

  describe '#sent' do
    it 'sets status and sent time' do
      expect(email.sent_to_mail_server_at).to be_nil
      expect(email.status).to eq 'not yet sent'
      email.sent
      expect(email.sent_to_mail_server_at).to be_present
      expect(email.status).to eq 'sent'
    end
  end

end
