require 'rails_helper'

RSpec.describe PhaseUpdater do

  let(:contest) { Fabricate(:contest, status: 'submission') }

  it 'creates new stamp of product list for each contest phase' do
    contest_request = Fabricate(:contest_request,
                                contest: contest,
                                status: 'submitted')
    lookbook = Fabricate(:lookbook, contest_request: contest_request)
    Fabricate(:lookbook_image, phase: 'initial', lookbook: lookbook)
    initial_lookbook_detail_number = 2
    new_phase = ContestPhases.status_to_phase('fulfillment_ready')

    PhaseUpdater.new(contest_request).monitor_phase_change { contest_request.winner! }
    items = contest_request.lookbook.lookbook_details
    expect(items.count).to eq initial_lookbook_detail_number * 2
    expect(items.where(phase: new_phase).count).to eq initial_lookbook_detail_number
  end

end
