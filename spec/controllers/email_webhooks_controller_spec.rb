require 'rails_helper'

RSpec.describe EmailWebhooksController do

  let(:params) do { 'mandrill_events' => webhook_example_events('inbound').to_json }
  end

  describe 'inbound webhook' do
    it 'saves email in db' do
      expect do
        post :create, params
      end.to change { InboundEmail.count }.from(0).to(1)
    end
  end



end
