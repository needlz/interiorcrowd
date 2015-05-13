require 'rails_helper'
require 'spec_helper'

RSpec.describe DesignerCenterController do
  render_views

  let(:designer) { Fabricate(:designer) }
  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:contest, client: client) }
  let(:request) { Fabricate(:contest_request, designer: designer, contest: contest) }

  describe 'GET designer_center' do
    it 'can not be accessed by anonymous user' do
      get :designer_center
      expect(response).to redirect_to designer_login_sessions_path
    end

    it 'can not be accessed by a client' do
      sign_in(client)
      get :designer_center
      expect(response).to redirect_to designer_login_sessions_path
    end

    context 'if logged as designer' do
      before do
        sign_in(designer)
      end

      context 'portfolio exists' do
        before do
          Fabricate(:portfolio, designer: designer)
        end

        it 'redirects to portfolio editing if the designer has no active requests' do
          get :designer_center
          expect(response).to redirect_to updates_designer_center_index_path
        end

        it 'redirects to responses list if the designer has active requests' do
          Fabricate(:contest_request, designer: designer, contest: Fabricate(:contest))
          get :designer_center
          expect(response).to redirect_to updates_designer_center_index_path
        end
      end

    end
  end

  describe 'GET updates' do
    before do
      sign_in(designer)
    end

    let!(:concept_board_comment) { Fabricate(:concept_board_client_comment, user_id: client.id, contest_request: request) }
    let!(:contest_comment) { contest.notes.create!(text: 'a note for designers', client_id: client.id) }
    let!(:contest_comment_form_other_designer) { contest.notes.create!(text: 'a note from other designer', designer_id: Fabricate(:designer).id) }
    let!(:notification) { Fabricate(:designer_invite_notification, designer: designer, contest: contest) }
    let!(:winner_notification) { DesignerWinnerNotification.create!(user_id: designer.id, contest_id: contest.id) }
    let!(:loser_notification) { DesignerLoserInfoNotification.create!(user_id: designer.id, contest_id: contest.id) }

    it 'renders page' do
      get :updates
      expect(response).to render_template(:updates)
    end
  end
end
