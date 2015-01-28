require 'rails_helper'

RSpec.describe ReviewerInvitationsController do
  render_views

  let(:designer) { Fabricate(:designer) }
  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:contest, client: client) }

  describe 'POST create' do
    let(:email) { 'email@example.com  ' }
    let(:username) { 'Dave Greenfield  ' }

    def params(options = {})
      { reviewer_invitation: { email: email, username: username, contest_id: contest.id }.merge(options) }
    end

    context 'not logged in' do
      it 'redirects to login page' do
        post :create, params
        expect(response).to redirect_to client_login_sessions_path
      end
    end

    context 'not creator of a contest' do
      before do
        sign_in(Fabricate(:client))
      end

      it 'doesn\'t create an invitation' do
        post :create, params
        expect(response).to render_template(ApplicationController::PAGE_404_PATH)
      end
    end

    context 'logged in' do
      before do
        sign_in(client)
      end

      context 'empty username passed' do
        it 'doesn\'t create an invitation' do
          expect { post :create, params(username: '') }.to raise_error
        end
      end

      context 'empty email passed' do
        it 'doesn\'t create an invitation' do
          expect { post :create, params(email: '') }.to raise_error
        end
      end

      context 'wrong contest id passed' do
        it 'doesn\'t create an invitation' do
          expect { post :create, params(contest_id: 0) }.to raise_error
        end
      end

      context 'correct params' do
        it 'creates an invitation' do
          post :create, params
          reviewer_invitation = contest.reviewer_invitations[0]
          expect(reviewer_invitation.username).to eq username.strip
          expect(reviewer_invitation.email).to eq email.strip
        end

        it 'generates url for an invitation' do
          post :create, params
          reviewer_invitation = contest.reviewer_invitations[0]
          expect(reviewer_invitation.url).to be_present
        end

        it 'notifies about success' do
          post :create, params
          expect(response).to be_ok
        end
      end
    end
  end

end
