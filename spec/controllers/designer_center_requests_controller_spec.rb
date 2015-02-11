require 'rails_helper'

RSpec.describe DesignerCenterRequestsController do
  render_views

  let(:designer) { Fabricate(:designer) }
  let(:client) { Fabricate(:client) }
  let(:other_designer) { Fabricate(:designer) }
  let(:contest) { Fabricate(:contest, client: client) }
  let(:other_contest) { Fabricate(:contest, client: client) }
  let(:submitted_request) do Fabricate(:contest_request,
                                      designer: designer,
                                      contest: contest,
                                      status: 'submitted',
                                      lookbook: Fabricate(:lookbook))
  end
  let(:draft_request) { Fabricate(:contest_request, designer: designer, contest: other_contest, status: 'draft') }
  let(:other_designers_request) { Fabricate(:contest_request, designer: other_designer, contest: contest) }

  before do
    sign_in(designer)
  end

  describe 'GET show' do
    it 'returns page' do
      get :show, id: submitted_request.id
      expect(response).to render_template(:show)
    end
  end

  describe 'GET index' do
    before do
      submitted_request
      draft_request
      other_designers_request
    end

    it 'returns page' do
      get :index
      expect(response).to render_template(:index)
    end

    it 'lists index of a designer' do
      get :index
      expect(assigns(:responses)).to eq [submitted_request, draft_request]
    end
  end

  describe 'PATCH update' do
    let(:new_feedback) { 'new feedback' }

    it 'updates feedback of response' do
      patch :update, id: submitted_request.id, contest_request: { feedback: new_feedback }
      expect(submitted_request.reload.feedback).to eq new_feedback
    end

    describe 'status' do
      it 'changes status to "submitted"' do
        patch :update, id: draft_request.id, contest_request: { status: 'submitted' }
        expect(draft_request.reload.status).to eq 'submitted'
      end

      it 'does not change status to any other status than "submitted"' do
        (ContestRequest::STATUSES - ['submitted']).each do |status|
          patch :update, id: draft_request.id, contest_request: { status: status }
          expect(draft_request.reload.status).to eq 'draft'
        end
      end
    end
  end

  describe 'GET new' do
    it 'returns page' do
      get :new, contest_id: contest.id
      expect(response).to render_template(:new)
    end

    context 'response already exists' do
      let!(:response) { Fabricate(:contest_request, contest: contest, designer: designer) }

      it 'redirects to view of existing response' do
        get :new, contest_id: contest.id
        expect(response).to redirect_to designer_center_response_path(id: response.id)
      end
    end
  end

  describe 'POST create' do
    it 'creates response' do
      expect(designer.contest_requests).to be_empty
      post :create, contest_id: contest.id, contest_request: { feedback: '' }
      expect(contest.requests[0].contest).to eq contest
      expect(contest.requests[0].status).to eq 'draft'
    end

    it 'sets status of request to "submitted" if "submitted" status passed' do
      post :create, contest_id: contest.id, contest_request: { feedback: '', status: 'submitted' }
      expect(contest.requests[0].status).to eq 'submitted'
    end

    it 'sets status of request to "draft" if not "submitted" status passed' do
      post :create, contest_id: contest.id, contest_request: { feedback: '', status: 'submitted' }
      expect(contest.requests[0].status).to eq 'submitted'
    end

    it 'raises error if contest not specified' do
      expect { post :create, contest_id: 0, contest_request: { feedback: '' } }.to raise_error
    end

    it 'creates lookbook' do
      image = Fabricate(:image)
      post :create, contest_id: contest.id, lookbook: { picture: { ids: [image.id] } }, contest_request: { feedback: '' }
      expect(contest.requests[0].lookbook.lookbook_details).to be_present
    end
  end
end
