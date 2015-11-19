require 'rails_helper'

RSpec.describe ContestPage do
  let(:client){ Fabricate(:client) }
  let(:designer){ Fabricate(:designer) }
  let(:contest){ Fabricate(:contest, client: client, status: 'submission') }
  let(:contest_page){ ContestPage.new(
    contest: contest,
    view_context: RenderingHelper.new
  ) }

  describe 'retrieving contest notes' do
    let(:client_note){ ContestNote.create(client: client, contest: contest, text: 'test') }
    let(:designer_note){ ContestNote.create(designer: designer, contest: contest, text: 'test') }


    it 'returns only client\'s notes' do
      client_note
      designer_note
      expect(contest_page.notes.count).to eq(1)
    end
  end

  describe 'retrieving contest requests' do
    let(:draft_contest_request) { Fabricate(:contest_request, contest: contest, status: 'draft') }
    let(:commenting_designer) { Fabricate(:designer) }
    let(:commented_contest_request) { Fabricate(:contest_request, contest: contest, designer: commenting_designer) }
    let(:designer_comment) { Fabricate(:concept_board_designer_comment, contest_request: commented_contest_request) }
    let(:another_designer) { Fabricate(:designer) }
    let(:closed_contest_request) { Fabricate(:contest_request,
                                             contest: contest,
                                             designer: another_designer,
                                             status: 'closed') }

    it 'returns only commented contest requests and requests not in draft' do
      draft_contest_request
      commented_contest_request
      designer_comment
      closed_contest_request
      expect(contest_page.contest_requests).not_to include(draft_contest_request)
      expect(contest_page.contest_requests).to match_array([commented_contest_request, closed_contest_request])
    end

  end


end
