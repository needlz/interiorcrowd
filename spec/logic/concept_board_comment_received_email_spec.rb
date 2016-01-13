require 'rails_helper'

RSpec.describe ConceptBoardCommentReceivedEmail do

  let(:parser) { ConceptBoardCommentReceivedEmail.new(inbound_email) }

  let(:designer) { Fabricate(:designer) }
  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:contest, status: 'submission') }
  let(:contest_request) { Fabricate(:contest_request, contest: contest, designer: designer) }
  let(:inbound_without_comment) { webhook_example_event('inbound') }
  let(:inbound_with_comment) do
    email = webhook_example_event('inbound_reply')
    email['msg']['to'][0][0] = "concept-board-#{ contest_request.id }@#{ ConceptBoardCommentReceivedEmail::INBOUND_DOMAIN }"
    email
  end

  describe '#concept_board_comment?' do

    context 'when sent to concept_board email address' do
      let(:inbound_email) { inbound_with_comment }

      it 'returns true' do
        expect(parser.contest_request_id).to be_present
      end
    end

    context 'when sent not to concept_board email address' do
      let(:inbound_email) { inbound_without_comment }

       it 'returns false' do
         expect(parser.contest_request_id).to be_nil
       end
    end
  end

  describe '#comment_text' do
    let(:inbound_email) { inbound_with_comment }

    it 'returns text of comment' do
      expect(parser.comment_text).to eq Griddler::EmailParser.extract_reply_body(inbound_with_comment['msg']['text'])
    end
  end

end
