require 'rails_helper'

RSpec.describe AvailableContestsQuery do

  let(:designer) { Fabricate(:designer) }
  let(:client) { Fabricate(:client) }

  let(:closed_contest) { Fabricate(:contest, client: client, status: 'closed') }
  let(:submission_contest) { Fabricate(:contest, client: client, status: 'submission') }
  let(:invited_contest) { Fabricate(:contest, client: client, status: 'submission') }
  let(:winner_selection_contest) { Fabricate(:contest, client: client, status: 'winner_selection') }
  let(:fulfillment_contest) { Fabricate(:contest, client: client, status: 'fulfillment') }
  let(:finished_contest) { Fabricate(:contest, client: client, status: 'finished') }

  let(:contests) { [closed_contest, winner_selection_contest, fulfillment_contest, finished_contest, submission_contest] }

  let(:available_contests) { AvailableContestsQuery.new(designer) }

  it 'returns list of active contests' do
    expect(available_contests.all).to match_array [submission_contest, invited_contest]
  end

  context 'invited to contests' do
    before do
      [invited_contest, winner_selection_contest].each do |contest|
        Fabricate(:designer_invite_notification, designer: designer, contest: contest)
      end
    end

    it 'returns list of current contests a designer was invited to' do
      expect(available_contests.invited).to match_array [invited_contest]
    end
  end

end
