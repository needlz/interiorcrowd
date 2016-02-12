require 'rails_helper'

RSpec.describe AddEmailToNewsletter do
  let(:client) { Fabricate(:client) }

  it 'adds user to newsletter' do
    stub_request(:post, "https://apikey:1234-us1@us1.api.mailchimp.com/3.0/lists/123/members")
    expect { AddEmailToNewsletter.perform(client) }.to_not raise_error
  end

end
