require 'rails_helper'

RSpec.describe ContestNoteCreation do

  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:contest_in_submission, client: client) }
  let(:designer) { Fabricate(:designer) }
  let(:contest_request) { Fabricate(:contest_request, contest: contest, designer: designer) }

  context 'logged in as client' do
    let(:current_user) { client }

    context 'designer has contest request' do
      before do
        contest_request
      end

      it 'creates contest comment and concept board comment' do
        comment_text = 'text  '
        creation = ContestNoteCreation.new(contest, comment_text, current_user)
        creation.perform
        expect(contest.notes[0].text).to eq comment_text.strip
        expect(contest_request.comments).to be_present
      end
    end

    context 'designer do not have contest request' do
      it 'creates contest comment' do
        creation = ContestNoteCreation.new(contest, 'text', current_user)
        creation.perform
        expect(contest.notes).to be_present
        expect(contest_request.comments).to_not be_present
      end
    end
  end

  context 'logged in as designer' do
    let(:current_user) { client }

    it 'creates contest comment' do
      creation = ContestNoteCreation.new(contest, 'text', current_user)
      creation.perform
      expect(contest.notes).to be_present
      expect(contest_request.comments).to_not be_present
    end
  end

end
