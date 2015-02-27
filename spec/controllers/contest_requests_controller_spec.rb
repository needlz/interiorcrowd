require 'rails_helper'
require 'spec_helper'

RSpec.describe ContestRequestsController do
  render_views

  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:contest, client: client) }
  let(:designer) { Fabricate(:designer) }
  let(:request) { Fabricate(:contest_request, contest: contest, lookbook: Fabricate(:lookbook), designer: designer) }

  describe 'POST answer' do
    before do
      sign_in(client)
    end

    let(:answered) { JSON.parse(response.body)['answered'] }

    context 'contest in "winner selection" state' do
      before do
        request
        contest.update_attributes!(status: 'winner_selection')
      end

      it 'saves if answer is winner' do
        post :answer, id: request.id, answer: 'winner'
        expect(answered).to eq true
      end

      it 'saves if answer is no' do
        post :answer, id: request.id, answer: 'no'
        response.body
        expect(answered).to eq true
      end

      it 'saves if answer is favorite' do
        post :answer, id: request.id, answer: 'favorite'
        expect(answered).to eq true
      end

      it 'saves if answer is maybe' do
        post :answer, id: request.id, answer: 'maybe'
        expect(answered).to eq true
      end

      it 'does not save if answer is unknown' do
        post :answer, id: request.id, answer: 'what?'
        expect(answered).to eq false
      end

      it 'does not save if request id is wrong' do
        expect { post :answer, id: 0, answer: 'no' }.to raise_exception
      end

      it 'does not save if user is not logged as contest creator' do
        session[:client_id] = nil
        post :answer, id: request.id, answer: 'no'
        expect(response).to redirect_to client_login_sessions_path
      end

      it 'changes status if answer is winner' do
        post :answer, id: request.id, answer: 'winner'
        expect(request.reload.status).to eq('fulfillment')
      end

      it 'creates winner notification if answer is winner' do
        post :answer, id: request.id, answer: 'winner'
        expect(UserNotification.exists?(user_id: request.designer_id, contest_id: request.contest_id, type: 'DesignerWinnerNotification')).to eq(true)
      end
    end

    it 'saves answer if contest is in submission state' do
      expect(contest.status).to eq 'submission'
      post :answer, id: request.id, answer: 'favorite'
      expect(answered).to be_truthy
    end

    it 'does not save answer if contest is not in winner selection or submission state' do
      request
      contest.start_winner_selection!
      contest.winner_selected!
      request.update_attributes!(status: 'fulfillment')
      post :answer, id: request.id, answer: 'favorite'
      expect(answered).to be_falsey
    end

    context 'contest in "submission" state' do
      before do
        contest.update_attributes!(status: 'submission')
      end

      let!(:request) { Fabricate(:contest_request, contest_id: contest.id, status: 'submitted', designer_id: 1) }
      let!(:request_with_answer) { Fabricate(:contest_request, contest_id: contest.id, status: 'submitted', designer_id: 2, answer: 'maybe') }
      let!(:request_without_answer) { Fabricate(:contest_request, contest_id: contest.id, status: 'submitted', designer_id: 3) }

      it 'should close requests which were not won and has answer' do
        post :answer, id: request.id, answer: 'winner'
        expect(request_with_answer.reload.status).to eq('closed')
      end

      it 'should close requests which were not won and has no answer' do
        post :answer, id: request.id, answer: 'winner'
        expect(request_without_answer.reload.status).to eq('closed')
      end
    end
  end

  describe 'POST approve_fulfillment' do
    before do
      sign_in(client)
    end

    let(:contest_request) { Fabricate(:contest_request, contest: contest, designer: designer, status: 'fulfillment_ready') }

    it 'changes status to fulfillment_approved' do
      post :approve_fulfillment, id: contest_request.id
      expect(contest_request.reload.status).to eq('fulfillment_approved')
      expect(response).to be_ok
    end

    it 'sends notification' do
      post :approve_fulfillment, id: contest_request.id
      expect(UserNotification.exists?(user_id: contest_request.designer_id, contest_id: contest_request.contest_id, type: 'DesignerInfoNotification')).to eq(true)
    end
  end

  describe 'POST add_comment' do
    context 'logged as contest owner' do
      before do
        sign_in(client)
      end

      it 'creates comment' do
        post :add_comment, comment: {text: 'text', contest_request_id: request.id}, id: request.id
        expect(ConceptBoardComment.exists?(text: 'text',
                                           contest_request_id: request.id,
                                           user_id: client.id)).to be_truthy
        expect(response).to be_ok
      end
    end

    context 'logged as other client' do
      before do
        sign_in(Fabricate(:client))
      end

      it 'renders 404' do
        post :add_comment, comment: {text: 'text', contest_request_id: request.id}, id: request.id
        expect(ConceptBoardComment.exists?).to be_falsey
        expect(response).to render_template(ApplicationController::PAGE_404_PATH)
      end
    end

    context 'logged as request creator' do
      before do
        sign_in(designer)
      end

      it 'creates comment' do
        post :add_comment, comment: {text: 'text', contest_request_id: request.id}, id: request.id
        expect(ConceptBoardComment.exists?(text: 'text',
                                           contest_request_id: request.id,
                                           user_id: designer.id)).to be_truthy
        expect(response).to be_ok
      end
    end

    context 'not creator of request' do
      before do
        sign_in(Fabricate(:designer))
      end

      it 'renders 404' do
        post :add_comment, comment: {text: 'text', contest_request_id: request.id}, id: request.id
        expect(ConceptBoardComment.exists?).to be_falsey
        expect(response).to render_template(ApplicationController::PAGE_404_PATH)
      end
    end
  end

  describe 'GET show' do
    before do
      sign_in(client)
    end

    it 'redirects to login page if user not logged in' do
      session[:client_id] = nil
      get :show, id: request.id
      expect(response).to redirect_to client_login_sessions_path
    end

    it 'returns page' do
      get :show, id: request.id
      expect(response).to render_template(:show)
    end

    it 'renders answers if contest is in submission state' do
      expect(contest.status).to eq 'submission'
      get :show, id: request.id
      expect(response).to render_template(partial: '_moodboard_answers')
    end

    it 'raises error if client is not logged in' do
      session[:client_id] = 0
      expect { get :show, id: request.id }.to raise_error
    end

    it 'raises error if request id is wrong' do
      expect { get :show, id: 0 }.to raise_error
    end
  end

  describe 'GET download' do
    context 'not logged in' do
      it 'redirects to client login' do
        get :download, id: request.id
        expect(response).to redirect_to client_login_sessions_path
      end
    end

    context 'logged as the client' do
      before do
        sign_in(client)
      end

      it 'redirects to original file' do
        stubbed_url = 'url'
        allow_any_instance_of(ContestRequest).to receive(:download_url) { stubbed_url }
        get :download, id: request.id
        expect(response).to redirect_to stubbed_url
      end
    end
  end
end
