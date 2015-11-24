require 'rails_helper'

RSpec.describe ContestPage do
  let(:client){ Fabricate(:client) }
  let(:designer){ Fabricate(:designer) }
  let(:contest){ Fabricate(:contest_in_submission, client: client) }
  let(:contest_page){ ContestPage.new(
    contest: contest,
    view_context: RenderingHelper.new
  ) }

  describe 'retrieving contest notes' do
    let(:client_note){ Fabricate(:contest_note, client: client, contest: contest) }
    let(:designer_note){ Fabricate(:contest_note, designer: designer, contest: contest) }


    it 'returns only client\'s notes' do
      client_note
      designer_note
      expect(contest_page.notes.count).to eq(1)
    end
  end

  describe 'retrieving contest requests' do
    let(:draft_contest_request) { Fabricate(:draft_request, contest: contest) }
    let(:commenting_designer) { Fabricate(:designer) }
    let(:commented_contest_request) { Fabricate(:contest_request, contest: contest, designer: commenting_designer) }
    let(:designer_comment) { Fabricate(:concept_board_designer_comment, contest_request: commented_contest_request) }
    let(:another_designer) { Fabricate(:designer) }
    let(:closed_contest_request) { Fabricate(:closed_request,
                                             contest: contest,
                                             designer: another_designer) }

    it 'returns only commented contest requests and requests not in draft' do
      draft_contest_request
      commented_contest_request
      designer_comment
      closed_contest_request
      expect(contest_page.contest_requests).not_to include(draft_contest_request)
      expect(contest_page.contest_requests).to match_array([commented_contest_request, closed_contest_request])
    end

  end

  describe 'inviting of the designers' do
    context 'contest in submission' do
      it 'shows invite designers link' do
        expect(contest_page.show_invite_designers_link?).to be_truthy
      end
    end

    context 'contest during winner selection' do
      let(:contest){ Fabricate(:contest_during_winner_selection, client: client) }
      let(:contest_page){ ContestPage.new(
          contest: contest,
          view_context: RenderingHelper.new
      ) }

      it 'doesn\'t show invite designers link' do
        expect(contest_page.show_invite_designers_link?).to be_falsey
      end
    end

  end


end
