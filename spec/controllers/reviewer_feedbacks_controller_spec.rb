require 'rails_helper'

RSpec.describe ReviewerFeedbacksController do
  render_views

  let(:designer) { Fabricate(:designer) }
  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:contest, client: client) }

  let(:text) { 'a comment on moodboards' }
  let!(:invitation) { Fabricate(:reviewer_invitation, contest_id: contest.id) }
  let(:invitation_token) { invitation.url }

  describe 'POST create' do
    def params(options = {})
      { id: contest.id,
        token: invitation_token,
        reviewer_feedback: { text: text } }.deep_merge(options)
    end

    context 'empty feedback' do
      it 'doesn\'t create an feedback' do
        expect { post :create, params(reviewer_feedback: { text: '  ' }) }.to raise_error
      end
    end

    context 'unexisting token' do
      it 'doesn\'t create an invitation' do
        post :create, params(token: '')
        expect(response).to render_template(ApplicationController::PAGE_404_PATH)
      end
    end

    context 'correct params' do
      it 'creates an feedback' do
        post :create, params
        feedback = contest.reviewer_feedbacks[0]
        expect(feedback.text).to eq text.strip
      end

      it 'notifies about success' do
        post :create, params
        expect(response).to be_ok
      end
    end
  end

  describe 'GET show' do

    context 'unexisting token' do
      it 'renders unknown path error' do
        get :show, id: contest.id
        expect(response).to render_template(ApplicationController::PAGE_404_PATH)
      end
    end

    context 'correct token' do
      it 'renders page' do
        get :show, id: contest.id, token: invitation_token
        expect(response).to render_template(:show)
      end
    end

  end

end
