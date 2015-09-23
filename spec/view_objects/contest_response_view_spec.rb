require "rails_helper"

RSpec.describe ContestResponseView do
  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:contest, client: client) }
  let(:contest_request) { Fabricate(:contest_request, status: 'fulfillment_ready', contest: contest) }

  it 'returns name of the design' do
    request_view = ContestResponseView.new(contest_request)
    expect(request_view.design_name).to eq(contest.project_name)
  end
end
