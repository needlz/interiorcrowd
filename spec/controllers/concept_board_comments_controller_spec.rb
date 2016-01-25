require 'rails_helper'

RSpec.describe ConceptBoardCommentsController, type: :controller do
  render_views

  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:contest, client: client, status: 'submission') }
  let(:fulfillment_contest) { Fabricate(:contest, client: client, status: 'fulfillment') }
  let(:designer) { Fabricate(:portfolio).designer }
  let(:request) { Fabricate(:contest_request, contest: contest,
                            lookbook: Fabricate(:lookbook),
                            designer: designer) }

  describe 'POST /:contest_request_id/create' do
    context 'logged as contest owner' do
      before do
        sign_in(client)
      end

      it 'creates comment' do
        post :create, comment: { text: 'text', contest_request_id: request.id }, contest_request_id: request.id
        expect(ConceptBoardComment.exists?(text: 'text',
                                           contest_request_id: request.id,
                                           user_id: client.id)).to be_truthy
        expect(response).to be_ok
      end

      it 'returns html of new comment' do
        post :create,
             comment: { text: 'http://google.com', contest_request_id: request.id },
             contest_request_id: request.id
        json = JSON.parse(response.body)
        expect(json['comment_html']).to be_present
      end

      it 'notifies designer' do
        post :create, comment: { text: 'text', contest_request_id: request.id }, contest_request_id: request.id
        expect(designer.reload.user_notifications[0]).to be_kind_of(ConceptBoardCommentNotification)
      end
    end

    context 'logged as other client' do
      before do
        sign_in(Fabricate(:client))
      end

      it 'renders 404' do
        post :create, comment: { text: 'text', contest_request_id: request.id }, contest_request_id: request.id
        expect(ConceptBoardComment.exists?).to be_falsey
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'logged as request creator' do
      before do
        sign_in(designer)
      end

      it 'creates comment' do
        post :create, comment: { text: 'text', contest_request_id: request.id }, contest_request_id: request.id
        expect(ConceptBoardComment.exists?(text: 'text',
                                           contest_request_id: request.id,
                                           user_id: designer.id)).to be_truthy
        expect(response).to be_ok
      end

      it 'does not notify designer' do
        expect(designer.user_notifications).to be_empty
      end
    end

    context 'not creator of request' do
      before do
        sign_in(Fabricate(:designer))
      end

      it 'renders 404' do
        post :create, comment: { text: 'text', contest_request_id: request.id }, contest_request_id: request.id
        expect(ConceptBoardComment.exists?).to be_falsey
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /comment' do
    context 'logged as request creator' do
      before do
        sign_in(designer)
      end

      context 'when files attached' do
        let(:params) do
          { comment: { text: 'text', attachments_ids: [Fabricate(:image).id] },
            designer_center_contest_id: contest.id }
        end

        it 'creates concept_board_comment_attachment' do
          mock_file_download_url
          post :create, params
          expect(ContestRequest.last.comments.last.attachments.count).to eq 1
        end
      end

      it 'creates first comment and contest request if there is no request for this designer yet' do
        expect do
          post :create, comment: { text: 'text' }, designer_center_contest_id: contest.id
        end.to change{ ContestRequest.count }.by(1).and change { ConceptBoardComment.count }.by(1)
        expect(ContestRequest.last.comments).to be_present
        expect(response).to be_ok
      end

      it 'creates new comment right after first comment creation' do
        post :create, comment: { text: 'text' }, designer_center_contest_id: contest.id
        expect do
          post :create, comment: { text: 'text' }, designer_center_contest_id: contest.id
        end.to change { ConceptBoardComment.count }.by(1)
      end
    end

    context 'logged as client' do
      before do
        sign_in(Fabricate(:client))
      end

      it 'renders 404' do
        post :create, comment: { text: 'text' }, designer_center_contest_id: contest.id
        expect(ConceptBoardComment.exists?).to be_falsey
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'PATCH update' do
    let(:clients_comment) do
      Fabricate(:concept_board_comment, user_id: client.id, role: client.role, contest_request: request)
    end
    let(:new_text) { 'new text' }

    context 'when logged as comment author' do
      before do
        sign_in(client)
      end

      it 'updates comment' do
        post :update, comment: { text: new_text }, contest_request_id: request.id, id: clients_comment.id
        expect(clients_comment.reload.text).to eq new_text
        expect(response).to render_template(partial: 'designer_center_requests/edit/_comment')
      end
    end

    context 'when not logged as another client' do
      before do
        sign_in(Fabricate(:client))
      end

      it 'does not allow access to resource' do
        post :update, comment: { text: new_text }, contest_request_id: request.id, id: clients_comment.id
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when not logged as collocutor' do
      before do
        sign_in(request.designer)
      end

      it 'does not allow access to resource' do
        post :update, comment: { text: new_text }, contest_request_id: request.id, id: clients_comment.id
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE destroy' do
    let(:clients_comment) do
      Fabricate(:concept_board_comment, user_id: client.id, role: client.role, contest_request: request)
    end

    context 'when logged as comment author' do
      before do
        sign_in(client)
      end

      it 'deletes comment' do
        delete :destroy, contest_request_id: request.id, id: clients_comment.id
        expect(JSON.parse(response.body)['destroyed_comment_id']).to eq clients_comment.id
      end
    end

    context 'when not logged as another client' do
      before do
        sign_in(Fabricate(:client))
      end

      it 'does not allow to destroy comment' do
        delete :destroy, contest_request_id: request.id, id: clients_comment.id
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when not logged as collocutor' do
      before do
        sign_in(request.designer)
      end

      it 'does not allow to destroy comment' do
        delete :destroy, contest_request_id: request.id, id: clients_comment.id
        expect(response).to have_http_status(:not_found)
      end
    end
  end

end
