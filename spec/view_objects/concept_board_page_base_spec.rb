require 'rails_helper'

RSpec.describe ConceptBoardPage::Base do
  let(:contest) {  Fabricate(:contest_in_submission) }
  let(:designer) { Fabricate(:designer) }
  let(:designer_comment) { Fabricate(:concept_board_designer_comment, user_id: designer.id) }
  let(:client) { Fabricate(:client) }
  let(:client_comment) { Fabricate(:concept_board_client_comment, user_id: client.id) }
  let(:contest_request) { Fabricate(:contest_request,
                                    contest: contest,
                                    comments: [designer_comment, client_comment]) }
  let(:designer_final_note) { Fabricate(:final_note,
                                        author_role: 'Designer',
                                        author_id: designer.id,
                                        contest_request_id: contest_request.id) }
  let(:client_final_note) { Fabricate(:final_note,
                                        author_role: 'Client',
                                        author_id: client.id,
                                        contest_request_id: contest_request.id) }
  let(:client_contest_note) { Fabricate(:contest_note, contest: contest, client: client) }
  let(:designer_contest_note) { Fabricate(:contest_note, contest: contest, designer: designer) }
  let(:concept_board_page) {
    ConceptBoardPage::Base.new(contest_request: contest_request)
  }

  context 'only comments present' do
    it 'returns the final notes count while only comments present' do
      expect(concept_board_page.final_notes.length).to eq(2)
    end
  end

  context 'comments and designer contest notes present' do
    it 'returns the final notes count without designer contest note' do
      expect(concept_board_page.final_notes.length).to eq(2)
      designer_contest_note
      expect(concept_board_page.final_notes.length).to eq(2)
    end
  end

  context 'comments, final notes and client contest note present' do
    it 'returns the final notes count including comments, final notes and client contest notes' do
      client_contest_note
      client_final_note
      designer_final_note
      expect(concept_board_page.final_notes.length).to eq(5)
    end
  end

end
