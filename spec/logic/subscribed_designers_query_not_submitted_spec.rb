require 'rails_helper'

RSpec.describe SubscribedDesignersQueryNotSubmitted do

  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:contest, client: client, status: 'submission') }
  let(:designer_with_submitted_contest_request) { Fabricate(:designer) }
  let(:designer_without_submitted_contest_request) { Fabricate(:designer) }
  let(:designer_with_contest_comment) { Fabricate(:designer) }
  let!(:submitted_contest_request) { Fabricate(:contest_request,
                                              contest: contest,
                                              designer: designer_with_submitted_contest_request) }
  let!(:draft_contest_request) { Fabricate(:contest_request,
                                          contest: contest,
                                          designer: designer_without_submitted_contest_request,
                                          status: 'draft') }
  let!(:contest_note) { contest.notes.create!(designer_id: designer_with_contest_comment.id,
                                              text: 'a comment') }

  it 'returns subscribed designers without submitted requests' do
    query = SubscribedDesignersQueryNotSubmitted.new(contest)
    expect(query.designers).to match_array(
      [designer_without_submitted_contest_request,
       designer_with_contest_comment]
    )
  end

end
