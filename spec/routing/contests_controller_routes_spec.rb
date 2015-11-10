require "rails_helper"

RSpec.describe ContestsController do
  it 'routes "/payment_details" to page with credit cards details' do
    expect(get: '/contests/payment_details').to route_to('contests#payment_details')
  end

  it 'routes "/invite_designers" to corresponding page' do
    expect(get: '/contests/invite_designers').to route_to('contests#invite_designers')
  end
end
