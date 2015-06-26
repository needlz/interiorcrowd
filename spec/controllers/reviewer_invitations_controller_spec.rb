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
      { contest_id: contest.id, reviewer_invitation: { email: email, username: username } }.merge(options)
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
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'logged in' do
      before do
        sign_in(client)
      end

      context 'empty username passed' do
        it 'doesn\'t create an invitation' do
          expect { post :create, params(reviewer_invitation: { username: '' }) }.to raise_error
        end
      end

      context 'empty email passed' do
        it 'doesn\'t create an invitation' do
          expect { post :create, params(reviewer_invitation: { email: '' }) }.to raise_error
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
          json = JSON.parse(response.body)
          invitation = contest.reviewer_invitations[0]
          expect(json['url']).to eq show_reviewer_feedbacks_url(id: contest.id, token: invitation.url)
          expect(json['token']).to eq invitation.url
        end

        it 'creates mail job' do
          post :create, params
          expect(jobs_with_handler_like('invitation_to_leave_a_feedback').count).to eq 1
        end
      end
    end
  end

end
