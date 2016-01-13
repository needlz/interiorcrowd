require 'rails_helper'

RSpec.describe MandrillInboundEmailProcessor do

  let(:designer) { Fabricate(:designer) }
  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:contest, status: 'submission', client: client) }
  let(:contest_request) { Fabricate(:contest_request, contest: contest, designer: designer) }
  let(:comment_from_designer) { Fabricate(:concept_board_comment, role: designer.role, user_id: designer.id) }
  let(:comment_from_client) { Fabricate(:concept_board_comment, role: client.role, user_id: client.id) }
  let(:inbound_with_comment) do
    email = webhook_example_event('inbound_reply')
    email['msg']['to'][0][0] = "concept-board-#{ contest_request.id }@#{ ConceptBoardCommentReceivedEmail::INBOUND_DOMAIN }"
    email
  end
  let(:email_processor) { MandrillInboundEmailProcessor.new('', inbound_with_comment) }

  describe 'instance' do
    describe '#recipient' do
      context 'when email is from designer' do
        before do
          inbound_with_comment['msg']['from_email'] = comment_from_designer.author.email
          email_processor.process
        end

        it 'is a client' do
          expect(email_processor.recipient).to eq client
        end
      end

      context 'when email is from client' do
        before do
          inbound_with_comment['msg']['from_email'] = comment_from_client.author.email
          email_processor.process
        end

        it 'is a designer' do
          expect(email_processor.recipient).to eq designer
        end
      end
    end
  end

end

