require 'rails_helper'

RSpec.describe ClientCreation do

  let(:client_creation) { ClientCreation.new(client_attributes: default_client_options) }

  it 'subscribes a client to newsletter' do
    stub_gibbon_requests

    expect { client_creation.perform }.to change {
      jobs_with_handler_like(SubscribeToNewsletterJob.name).count
    }.from(0).to(1)
  end

end
