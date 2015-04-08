require 'rails_helper'

RSpec.describe DesignerCenterRequestsController do
  render_views

  let(:designer) { Fabricate(:designer) }
  let(:client) { Fabricate(:client) }
  let(:other_designer) { Fabricate(:designer) }
  let(:contest) { Fabricate(:contest, client: client, desirable_colors: '955e3a,ffb81b', undesirable_colors: 'EEE') }
  let(:other_contest) { Fabricate(:contest, client: client) }
  let(:submitted_request) do Fabricate(:contest_request,
                                      designer: designer,
                                      contest: contest,
                                      status: 'submitted',
                                      lookbook: Fabricate(:lookbook))
  end
  let(:finished_request) do Fabricate(:contest_request,
                                       designer: designer,
                                       contest: contest,
                                       status: 'finished',
                                       lookbook: Fabricate(:lookbook))
  end
  let(:fulfillment_ready_request) do Fabricate(:contest_request,
                                      designer: designer,
                                      contest: contest,
                                      status: 'fulfillment_ready',
                                      lookbook: Fabricate(:lookbook))
  end
  let(:closed_request) do Fabricate(:contest_request,
                                      designer: designer,
                                      contest: contest,
                                      status: 'closed',
                                      lookbook: Fabricate(:lookbook))
  end
  let(:draft_request) { Fabricate(:contest_request, designer: designer, contest: other_contest, status: 'draft') }
  let(:other_designers_request) { Fabricate(:contest_request, designer: other_designer, contest: contest) }

  before do
    sign_in(designer)
  end

  describe 'GET show' do
    it 'returns page of submitted request' do
      get :show, id: submitted_request.id
      expect(response).to render_template(:show)
    end

    it 'returns page of winner response' do
      submitted_request.update_attributes!(answer: 'winner')
      get :show, id: submitted_request.id
      expect(response).to render_template(:show)
    end

    it 'returns page for each phase view' do
      ContestPhases.indices.each do |index|
        get :show, id: finished_request.id, view: index
        expect(response).to render_template(:show)
      end
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
  end

  describe 'PATCH update' do
    let(:new_feedback) { 'new feedback' }

    it 'updates feedback of response' do
      patch :update, id: submitted_request.id, contest_request: { feedback: new_feedback }
      expect(submitted_request.reload.feedback).to eq new_feedback
    end

    it 'does not update if request is closed' do
      submitted_request.update_attributes!(status: 'closed')
      patch :update, id: submitted_request.id, contest_request: { feedback: new_feedback }
      expect(response).to have_http_status(:not_found)
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

    context 'request with fulfillment status' do
      let(:request){ Fabricate(:contest_request, designer: designer, contest: contest, status: 'fulfillment') }

      before do
        request.image_items.create!(kind: 'product_items')
        request.image_items.create!(kind: 'similar_styles')
      end

      it 'clears image items if no params passed' do
        expect(request.image_items.count).to eq 2
        patch :update, id: request.id
        expect(request.reload.image_items.count).to eq 0
      end
    end

    context 'request with fulfillment approved status' do
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

      it 'clears image items if no params passed' do
        request.image_items.create!(kind: 'product_items', mark: ImageItem::MARKS[:DISLIKE])
        request.image_items.create!(kind: 'similar_styles', mark: ImageItem::MARKS[:DISLIKE])
        request.image_items.create!(kind: 'product_items')
        request.image_items.create!(kind: 'similar_styles', mark: ImageItem::MARKS[:LIKE])
        expect(request.image_items.count).to eq 4
        patch :update, id: request.id
        expect(request.reload.image_items.count).to eq 2
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

    it 'does not create empty comment if comment does not exist' do
      expect(designer.contest_requests).to be_empty
      post :create, contest_id: contest.id, contest_request: { feedback: '' }
      expect(contest.requests[0].comments.first).to eq nil
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

    context 'request is finished' do
      it 'redirects to show page' do
        request = finished_request
        get :edit, id: request.id
        expect(response).to redirect_to(designer_center_response_path(id: request.id))
      end
    end

    it 'returns page for initial and fulfillment phases' do
      [0..1].each do |index|
        get :edit, id: fulfillment_ready_request.id, view: index
        expect(response).to render_template(:edit)
      end
    end
  end
end
