require 'rails_helper'

RSpec.describe SubscribedDesignersQueryNotSubmitted do

  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:contest_in_submission, client: client) }
  let!(:designer_with_submitted_contest_request) { Fabricate(:designer) }
  let!(:designer_without_submitted_contest_request) { Fabricate(:designer) }
  let!(:designer_with_contest_comment) { Fabricate(:designer) }
  let!(:invited_designer) { Fabricate(:designer) }
  let!(:not_invited_designer) { Fabricate(:designer) }
  let!(:submitted_contest_request) { Fabricate(:contest_request,
                                              contest: contest,
                                              designer: designer_with_submitted_contest_request) }
  let!(:draft_contest_request) { Fabricate(:contest_request,
                                          contest: contest,
                                          designer: designer_without_submitted_contest_request,
                                          status: 'draft') }
  let!(:contest_note) { contest.notes.create!(designer_id: designer_with_contest_comment.id,
                                              text: 'a comment') }
  let!(:designer_invitation) { Fabricate(:designer_invite_notification,
                                         designer: invited_designer,
                                         contest: contest) }

  it 'returns subscribed designers without submitted requests' do
    query = SubscribedDesignersQueryNotSubmitted.new(contest)
    expect(query.designers).to match_array(
      [designer_without_submitted_contest_request,
       designer_with_contest_comment,
       invited_designer,
       not_invited_designer]
    )
  end

end
