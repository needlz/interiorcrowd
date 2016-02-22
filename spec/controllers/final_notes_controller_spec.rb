require 'rails_helper'

RSpec.describe FinalNotesController do
  render_views

  let(:client) { Fabricate(:client) }
  let(:designer) { Fabricate(:designer, portfolio: Fabricate(:portfolio)) }
  let(:contest) { Fabricate(:contest_in_submission, client: client) }
  let(:contest_request){ Fabricate(:contest_request, contest: contest, designer: designer) }
  let(:text) { 'final note' }

  describe 'POST create' do
    context 'logged in as contest owner' do
      before do
        sign_in(client)
        post :create, contest_request_id: contest_request.id, final_note: { text: text }
      end

      it 'creates final note' do
        final_note = FinalNote.first
        expect(final_note.text).to eq text
        expect(final_note.author).to eq client
        expect(final_note.contest_request).to eq contest_request
      end

      it 'creates notification for designer' do
        expect(FinalNote.first.designer_notification).to be_present
      end
    end

    context 'logged in as other client' do
      before do
        sign_in(Fabricate(:client))
        post :create, contest_request_id: contest_request.id, final_note: { text: text }
      end

      it 'does not create final note' do
        expect(FinalNote.count).to be_zero
      end

      it 'returns 404 status' do
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'logged in as other designer' do
      before do
        sign_in(Fabricate(:designer))
      end

      it 'does not create final note' do
        post :create, contest_request_id: contest_request.id, final_note: { text: text }
        expect(FinalNote.count).to be_zero
      end
    end

    context 'logged in as contest request author' do
      before do
        sign_in(designer)
        post :create, contest_request_id: contest_request.id, final_note: { text: text }
      end

      it 'creates final note' do
        final_note = FinalNote.first
        expect(final_note.text).to eq text
        expect(final_note.author).to eq designer
        expect(final_note.contest_request).to eq contest_request
      end

      it 'does not create notification for designer' do
        expect(FinalNote.first.designer_notification).to be_nil
      end
    end

  end

end
