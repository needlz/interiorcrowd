require 'rails_helper'

RSpec.describe DesignerInvitationsController do
  render_views

  let(:designer) { Fabricate(:designer) }
  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:contest, client: client) }

  describe 'POST create' do
    context 'not logged in' do
      it 'redirects to login page' do
        post :create, designer_id: designer.id, contest_id: contest.id
        expect(response).to redirect_to client_login_sessions_path
      end
    end

    context 'not creator of a contest' do
      before do
        sign_in(Fabricate(:client))
      end

      it 'doesn\'t create an invitation' do
        post :create, designer_id: designer.id, contest_id: contest.id
        expect(response).to render_template(ApplicationController::PAGE_404_PATH)
      end
    end

    context 'logged in' do
      before do
        sign_in(client)
      end

      context 'unexisting designer id' do
        it 'doesn\'t create an invitation' do
          expect { post :create, designer_id: 0, contest_id: contest.id }.to raise_error
        end
      end

      context 'unexisting contest id' do
        it 'doesn\'t create an invitation' do
          expect { post :create, designer_id: designer.id, contest_id: 0 }.to raise_error
        end
      end

      context 'contest not in submission state' do
        before do
          contest.start_winner_selection!
        end

        it 'doesn\'t create an invitation' do
          expect { post :create, designer_id: designer.id, contest_id: contest.id }.to raise_error
        end
      end

      context 'correct designer and contest id' do
        it 'creates an invitation' do
          post :create, designer_id: designer.id, contest_id: contest.id
          designer_invitation = client.designer_invitations[0]
          expect(designer_invitation.designer).to eq designer
          expect(designer_invitation.contest).to eq contest
        end

        it 'notifies about success' do
          post :create, designer_id: designer.id, contest_id: contest.id
          expect(response).to be_ok
        end

        it 'doesn\'t create an invitation if already invited' do
          Fabricate(:designer_invitation, user_id: designer.id, contest_id: contest.id)
          expect { post :create, designer_id: designer.id, contest_id: contest.id }.to raise_error
        end
      end
    end
  end

end
