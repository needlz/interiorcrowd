require 'rails_helper'

RSpec.describe DesignerCenterRequestsController do
  render_views

  before do
    mock_file_download_url
  end

  let(:designer) { Fabricate(:designer_with_portfolio) }
  let(:client) { Fabricate(:client) }
  let(:other_designer) { Fabricate(:designer) }
  let(:contest) { Fabricate(:contest_in_submission,
                            client: client,
                            desirable_colors: '955e3a,ffb81b',
                            undesirable_colors: 'EEE') }
  let(:fulfillment_contest) { Fabricate(:completed_contest, client: client, status: 'fulfillment') }
  let(:final_fulfillment_contest) { Fabricate(:completed_contest, client: client, status: 'final_fulfillment') }
  let(:other_contest) { Fabricate(:contest_in_submission, client: client) }
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
  let(:fulfillment_approved_request) do Fabricate(:contest_request,
                                               designer: designer,
                                               contest: final_fulfillment_contest,
                                               status: 'fulfillment_approved',
                                               lookbook: Fabricate(:lookbook))
  end
  let(:closed_request) do Fabricate(:contest_request,
                                      designer: designer,
                                      contest: contest,
                                      status: 'closed',
                                      lookbook: Fabricate(:lookbook))
  end
  let(:draft_request) { Fabricate(:contest_request,
                                  designer: designer,
                                  contest: other_contest,
                                  status: 'draft') }
  let(:other_designers_request) { Fabricate(:contest_request,
                                            designer: other_designer,
                                            contest: contest) }

  before do
    sign_in(designer)
  end

  describe 'GET show' do
    context 'when concept board is submitted' do
      it 'returns page of submitted request' do
        get :show, id: submitted_request.id
        expect(response).to render_template(:show)
      end

      it 'returns page of winner response' do
        submitted_request.update_attributes!(answer: 'winner')
        get :show, id: submitted_request.id
        expect(response).to redirect_to edit_designer_center_response_path(id: submitted_request.id)
      end
    end

    context 'when contest is in winner_selection state' do
      before do
        contest.start_winner_selection!
      end

      it 'returns page' do
        ContestPhases.indices.each do |index|
          get :show, id: submitted_request.id, view: index
          expect(response).to render_template(:show)
        end
      end
    end

    context 'when concept board has final image items' do
      before do
        Fabricate.times(15, :product_item, contest_request: concept_board, status: 'published', phase: 'final_design')
      end

      context 'when concept board is finished' do
        let(:concept_board) { finished_request }

        it 'returns page for each phase view' do
          ContestPhases.indices.each do |index|
            get :show, id: concept_board.id, view: index
            expect(response).to render_template(:show)
            expect(assigns(:setup_viglink)).to be_truthy
          end
        end
      end

      context 'when concept board is fulfillment_approved' do
        let(:concept_board) { fulfillment_approved_request }

        it 'enables VigLink for the page' do
          ContestPhases.indices.each do |index|
            get :show, id: concept_board.id, view: index
            expect(assigns(:setup_viglink)).to be_truthy
          end
        end
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
      expect(response).to redirect_to designer_center_response_path(id: submitted_request.id)
    end

    describe 'status' do
      it 'changes status to "submitted"' do
        patch :update, id: draft_request.id, contest_request: { status: 'submitted' }
        expect(draft_request.reload.status).to eq 'submitted'
      end

      it 'redirects to Updates page' do
        patch :update, id: draft_request.id, contest_request: { status: 'submitted' }
        expect(response).to redirect_to designer_center_updates_path
      end

      it 'does not change status to any other status than "submitted"' do
        (ContestRequest::STATUSES - ['submitted']).each do |status|
          patch :update, id: draft_request.id, contest_request: { status: status }
          expect(draft_request.reload.status).to eq 'draft'
        end
      end

      it 'creates notification' do
        patch :update, id: draft_request.id, contest_request: { status: 'submitted' }
        expect(BoardSubmittedDesignerNotification.first.designer).to eq designer
      end
    end

    def product_list_params
      {
        contest_request: {
          product_items: {
            image_ids: [Fabricate(:image).id, Fabricate(:image)].join(','),
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
      let(:request){ Fabricate(:contest_request,
                               designer: designer,
                               contest: contest,
                               status: 'fulfillment_ready') }

      before do
        request.image_items.create!(kind: 'product_items')
        request.image_items.create!(kind: 'similar_styles')
      end

      it 'clears image items if no params passed' do
        expect(request.image_items.count).to eq 2
        patch :update, id: request.id
        expect(request.reload.image_items.count).to eq 0
      end

      it 'redirects to Updates page' do
        patch :update, id: request.id
        expect(response).to redirect_to designer_center_response_path(id: request.id)
      end
    end

    context 'request with fulfillment approved status' do
      let(:request){ Fabricate(:contest_request,
                               designer: designer,
                               contest: final_fulfillment_contest,
                               status: 'fulfillment_approved') }

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
        request.image_items.create!(kind: 'product_items',
                                    mark: ImageItem::MARKS[:DISLIKE],
                                    status: 'published',
                                    phase: 'final_design')
        request.image_items.create!(kind: 'similar_styles',
                                    mark: ImageItem::MARKS[:DISLIKE],
                                    status: 'published',
                                    phase: 'final_design')
        request.image_items.create!(kind: 'product_items',
                                    status: 'published',
                                    phase: 'final_design')
        request.image_items.create!(kind: 'similar_styles',
                                    mark: ImageItem::MARKS[:LIKE],
                                    status: 'published',
                                    phase: 'final_design')
        expect(request.image_items.count).to eq 4
        patch :update, id: request.id
        expect(request.reload.image_items.count).to eq 0
      end

      it 'finishes contest and contest request' do
        patch :update, id: request.id, contest_request: { status: 'finished' }
        expect(request.reload).to be_finished
        expect(request.contest.reload).to be_finished
      end

      it 'logs finish event to Mixpanel' do
        patch :update, id: request.id, contest_request: { status: 'finished' }
        expect(jobs_with_handler_like('MixpanelLogRecord').count).to eq 1
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

    it 'raises error if contest not specified' do
      post :create, contest_id: 0, contest_request: { feedback: '' }
      expect(response).to have_http_status(:not_found)
    end

    it 'creates lookbook' do
      image = Fabricate(:image)
      post :create,
           contest_id: contest.id,
           lookbook: { picture: { ids: image.id } },
           contest_request: { feedback: '' }
      expect(contest.requests[0].lookbook.lookbook_details).to be_present
    end

    it 'does not create empty comment if comment does not exist' do
      expect(designer.contest_requests).to be_empty
      post :create, contest_id: contest.id, contest_request: { feedback: '' }
      expect(contest.requests[0].comments.first).to eq nil
    end

    context 'contest winner already selected' do
      before do
        contest.update_attributes!(status: 'fulfillment')
      end

      it 'does not create request' do
        post :create, contest_id: contest.id, contest_request: { feedback: '' }
        expect(contest.requests).to be_empty
      end
    end

    context 'response already created' do
      let(:existing_request) { Fabricate(:contest_request, designer: designer, contest: contest) }

      before do
        existing_request
      end

      it 'redirects to response page' do
        post :create, contest_id: contest.id, contest_request: { feedback: '' }
        expect(response).to redirect_to designer_center_response_path(id: existing_request.id)
      end
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
        expect(response).to redirect_to designer_center_response_path(id: request.id)

        request.winner!
        get :edit, id: request.id
        expect(response).to render_template(:edit)

        request.approve_fulfillment!
        get :edit, id: request.id
        expect(response).to render_template(:edit)
        expect(assigns(:setup_viglink)).to be_truthy
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
      expect(contest.phase_end).to be_present
      [0..1].each do |index|
        get :edit, id: fulfillment_ready_request.id, view: index
        expect(response).to render_template(:edit)
        expect(assigns(:setup_viglink)).to be_truthy
      end
    end

    context 'when there are contest comments' do
      before do
        contest_comment = fulfillment_ready_request.contest.notes.create!(text: 'a comment',
                                                                          client_id: client.id)
        fulfillment_ready_request.comments.create!(
            contest_note_id: contest_comment.id,
            role: 'Client',
            user_id: client.id)
      end

      it 'returns page' do
        get :edit, id: fulfillment_ready_request.id
        expect(response).to render_template(:edit)
      end
    end
  end
end
