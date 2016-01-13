require 'rails_helper'

RSpec.describe ConceptBoardCommentEmail do

  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:contest, client: client, status: 'submission') }
  let(:contest_request) { Fabricate(:contest_request, contest: contest) }
  let!(:previous_comment_1) { Fabricate(:concept_board_comment, contest_request: contest_request) }
  let!(:previous_comment_2) { Fabricate(:concept_board_comment, contest_request: contest_request) }
  let!(:comment) { Fabricate(:concept_board_comment, contest_request: contest_request) }
  let(:email_1) { ConceptBoardCommentEmail.new(previous_comment_1) }
  let(:email_2) { ConceptBoardCommentEmail.new(previous_comment_2) }
  let(:last_comment_email) { ConceptBoardCommentEmail.new(comment) }

  describe 'instance' do
    describe '#message_id' do
      subject { last_comment_email.message_id }

      it { is_expected.to eq "<#{ contest_request.email_thread_id }_#{ comment.id }@#{ Settings.app_domain }>" }
    end

    describe '#references' do
      subject { last_comment_email.references }

      it { is_expected.to eq "#{ email_1.message_id } #{ email_2.message_id }" }
    end

    describe '#in_reply_to' do
      subject { last_comment_email.in_reply_to }

      it { is_expected.to eq email_2.message_id }
    end

    describe '#subject' do
      subject { last_comment_email.subject }

      it { is_expected.to eq "Concept board for \"#{ contest.name }\"" }
    end
  end

end
