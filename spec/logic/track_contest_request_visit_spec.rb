require 'rails_helper'

RSpec.describe TrackContestRequestVisit do

  describe '#perform' do
    let(:client) { Fabricate(:client) }
    let(:designer) { Fabricate(:designer) }
    let(:contest) { Fabricate(:contest_in_submission, client: client) }
    let(:contest_request) { Fabricate(:contest_request, contest: contest, designer: designer) }

    it 'saves current time' do
      TrackContestRequestVisit.perform(contest_request)
      expect(contest_request.last_visit_by_client_at).to be_within(5.second).of(Time.current)
    end
  end

end
