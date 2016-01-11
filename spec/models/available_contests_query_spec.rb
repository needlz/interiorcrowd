require 'rails_helper'

RSpec.describe AvailableContestsQuery do

  let(:designer) { Fabricate(:designer) }
  let(:client) { Fabricate(:client) }

  let(:closed_contest) { Fabricate(:contest, client: client, status: 'closed') }
  let(:submission_contest) { Fabricate(:contest, client: client, status: 'submission') }
  let(:submission_contest_with_draft_request) do
    contest = Fabricate(:contest, client: client, status: 'submission')
    Fabricate(:contest_request, contest: contest, designer: designer, status: 'draft')
    contest
  end
  let(:submission_contest_with_submitted_request) do
    contest = Fabricate(:contest, client: client, status: 'submission')
    Fabricate(:contest_request, contest: contest, designer: designer, status: 'submitted')
    contest
  end
  let(:invited_contest) { Fabricate(:contest, client: client, status: 'submission') }
  let(:winner_selection_contest) { Fabricate(:contest, client: client, status: 'winner_selection') }
  let(:fulfillment_contest) { Fabricate(:contest, client: client, status: 'fulfillment') }
  let(:finished_contest) { Fabricate(:contest, client: client, status: 'finished') }

  let(:contests) { [closed_contest,
                    winner_selection_contest,
                    fulfillment_contest,
                    finished_contest,
                    submission_contest,
                    submission_contest_with_draft_request,
                    submission_contest_with_submitted_request ] }

  let(:available_contests) { AvailableContestsQuery.new(designer) }

  before do
    contests
  end

  it 'returns list of active contests' do
    expect(available_contests.all).to match_array [submission_contest,
                                                   invited_contest,
                                                   submission_contest_with_draft_request,
                                                   submission_contest_with_submitted_request]
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

  it 'returns list of suggested contests' do
    expect(available_contests.suggested).to match_array [submission_contest, submission_contest_with_draft_request]
  end

end
