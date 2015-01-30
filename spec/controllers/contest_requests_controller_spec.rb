require 'rails_helper'
require 'spec_helper'

RSpec.describe ContestRequestsController do
  render_views

  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:contest, client: client) }
  let(:designer) { Fabricate(:designer) }
  let(:request) { Fabricate(:contest_request, contest: contest, lookbook: Fabricate(:lookbook), designer: designer) }

  before do
    sign_in(client)
  end

  describe 'POST answer' do
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
        session[:client_id] = 0
        post :answer, id: request.id, answer: 'no'
        expect(answered).to be_falsy
      end
    end

    it 'does not save answer if contest is not in winner selection state' do
      expect(contest.status).to eq 'submission'
      post :answer, id: request.id, answer: 'favorite'
      expect(answered).to be_falsy
    end
  end

  describe 'GET show' do
    it 'redirects to login page if user not logged in' do
      session[:client_id] = nil
      get :show, id: request.id
      expect(response).to redirect_to client_login_sessions_path
    end

    it 'returns page' do
      get :show, id: request.id
      expect(response).to render_template(:show)
    end

    it 'raises error if client is not logged in' do
      session[:client_id] = 0
      expect { get :show, id: request.id }.to raise_error
    end

    it 'raises error if request id is wrong' do
      expect { get :show, id: 0 }.to raise_error
    end
  end
end
