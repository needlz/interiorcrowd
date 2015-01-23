require 'rails_helper'

RSpec.describe DesignerInvitationsController do
  render_views

  let(:designer) { Fabricate(:designer) }
  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:contest, client: client) }

  describe 'POST create' do
    context 'not logged in' do
      it 'redirects to login page' do
        post :create, designer_id: designer.id, contest_id: contest.id, format: 'json'
        expect(response).to redirect_to client_login_sessions_path
      end
    end

    context 'not creator of a contest' do
      before do
        sign_in(Fabricate(:client))
      end

      it 'doesn\'t create an invitation' do
        post :create, designer_id: designer.id, contest_id: contest.id, format: 'json'
        expect(response).to render_template(ApplicationController::PAGE_404_PATH)
      end
    end

    context 'logged in' do
      before do
        sign_in(client)
      end

      context 'unexisting designer id' do
        it 'doesn\'t create an invitation' do
          post :create, designer_id: 0, contest_id: contest.id, format: 'json'
          json = JSON.parse(response.body)
          expect(json['success']).to eq false
        end
      end

      context 'unexisting contest id' do
        it 'doesn\'t create an invitation' do
          expect { post :create, designer_id: designer.id, contest_id: 0, format: 'json' }.to raise_error
          expect(client.designer_invitations.count).to eq 0
        end
      end

      context 'contest not in submission state' do
        before do
          contest.start_winner_selection!
        end

        it 'doesn\'t create an invitation' do
          post :create, designer_id: designer.id, contest_id: contest.id, format: 'json'
          json = JSON.parse(response.body)
          expect(json['success']).to eq false
        end
      end

      context 'correct designer and contest id' do
        it 'creates an invitation' do
          post :create, designer_id: designer.id, contest_id: contest.id, format: 'json'
          designer_invitation = client.designer_invitations[0]
          expect(designer_invitation.designer).to eq designer
          expect(designer_invitation.contest).to eq contest
        end

        it 'notifies about success' do
          post :create, designer_id: designer.id, contest_id: contest.id, format: 'json'
          json = JSON.parse(response.body)
          expect(json['success']).to eq true
        end

        it 'doesn\'t create an invitation if already invited' do
          Fabricate(:designer_invitation, designer_id: designer.id, contest_id: contest.id)
          post :create, designer_id: designer.id, contest_id: contest.id, format: 'json'
          json = JSON.parse(response.body)
          expect(json['success']).to eq false
        end
      end
    end
  end

end
