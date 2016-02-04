require 'rails_helper'

RSpec.describe ContestResponseView do
  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:contest, client: client, status: 'brief_pending') }
  let(:contest_request) { Fabricate(:contest_request, status: 'fulfillment_ready', contest: contest) }

  it 'returns name of the design' do
    request_view = ContestResponseView.new(contest_request)
    expect(request_view.design_name.include?(client.first_name)).to be_truthy
  end

  it 'contains client first name in possessive form' do
    client.update_attribute(:first_name, 'Dave')
    request_view = ContestResponseView.new(contest_request)
    expect(request_view.design_name.include?('Dave’s ')).to be_truthy
  end

  it "contains client first name ending in 's' also in its own possessive form" do
    client.update_attribute(:first_name, 'Amadeus')
    request_view = ContestResponseView.new(contest_request)
    expect(request_view.design_name.include?('Amadeus’ rooms')).to be_truthy
  end

  it 'contains client last name if there is no first name' do
    client.update_attribute(:first_name, nil)
    request_view = ContestResponseView.new(contest_request)
    expect(request_view.design_name.include?(client.last_name)).to be_truthy
  end

  it 'contains client email if there is no first or last name' do
    client.update_attribute(:first_name, nil)
    client.update_attribute(:last_name, nil)
    request_view = ContestResponseView.new(contest_request)
    expect(request_view.design_name.include?(client.email)).to be_truthy
  end
end
