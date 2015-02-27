require 'rails_helper'

RSpec.describe DesignerCenterRequestsController do
  render_views

  let(:designer) { Fabricate(:designer) }
  let(:client) { Fabricate(:client) }
  let(:other_designer) { Fabricate(:designer) }
  let(:contest) { Fabricate(:contest, client: client, desirable_colors: '955e3a,ffb81b',undesirable_colors: 'EEE') }
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

    def product_list_params
      {
        contest_request: {
          product_items: {
            image_ids: [Fabricate(:image), Fabricate(:image)].join(','),
            texts: ['text 1', 'text 2'],
            ids: ['', '']
          }
        }
      }
    end

    it 'updates products list' do
      patch :update, product_list_params.merge({ id: submitted_request.id })
      expect(submitted_request.product_items.count).to eq 2
    end

    context 'fulfillment approved' do
      let(:request){ Fabricate(:contest_request, designer: designer, contest: contest, status: 'fulfillment_approved') }

      it 'updates final note' do
        new_final_note = 'new note'
        patch :update, id: request.id, contest_request: { final_note: new_final_note }
        expect(request.reload.final_note).to eq new_final_note
      end

      it 'updates pull together note' do
        new_pull_together_note = 'new pull together note'
        patch :update, id: request.id, contest_request: { pull_together_note: new_pull_together_note }
        expect(request.reload.pull_together_note).to eq new_pull_together_note
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

  describe 'GET edit' do
    context 'request has draft status' do
      it 'redirects to show page' do
        request = draft_request
        get :edit, id: request.id
        expect(response).to redirect_to designer_center_response_path(id: request.id)
      end
    end

    context 'request was submitted' do
      it 'renders page' do
        request = submitted_request

        get :edit, id: request.id
        expect(response).to render_template(:edit)

        request.winner!
        get :edit, id: request.id
        expect(response).to render_template(:edit)

        request.ready_fulfillment!
        get :edit, id: request.id
        expect(response).to render_template(:edit)

        request.approve_fulfillment!
        get :edit, id: request.id
        expect(response).to render_template(:edit)
      end
    end
  end
end
