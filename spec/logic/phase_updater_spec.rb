require 'rails_helper'

RSpec.describe PhaseUpdater do

  let(:contest) { Fabricate(:contest, status: 'submission') }

  it 'creates new stamp of product list for each contest phase' do
    contest_request = Fabricate(:contest_request, contest: contest, status: 'submitted')
    lookbook = Fabricate(:lookbook, contest_request: contest_request)
    Fabricate(:lookbook_image, phase: 'initial', lookbook: lookbook)
    new_phase = ContestPhases.status_to_phase('fulfillment')

    PhaseUpdater.new(contest_request).perform_phase_change { contest_request.winner! }
    expect(contest_request.lookbook.lookbook_details.where(phase: new_phase).count).to eq 1
  end

end
