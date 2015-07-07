require 'rails_helper'

RSpec.describe FinalNoteToDesignerController do
  render_views

  let(:client) { Fabricate(:client) }
  let(:designer) { Fabricate(:designer) }
  let(:contest) { Fabricate(:contest, client: client, status: 'submission') }
  let(:contest_request){ Fabricate(:contest_request, contest: contest, designer: designer) }
  let(:text) { 'final note' }

  describe 'POST create' do
    before do
      sign_in(client)
    end

    it 'creates final note' do
      post :create, contest_request_id: contest_request.id, final_note: { text: text }
      expect(FinalNoteToDesigner.first.text).to eq text
    end
  end

end
