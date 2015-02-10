require 'rails_helper'
require 'spec_helper'

RSpec.describe DesignerCenterController do
  render_views

  let(:designer) { Fabricate(:designer) }
  let(:client) { Fabricate(:client) }

  describe 'GET designer_center' do
    it 'can not be accessed by anonymous user' do
      get :designer_center
      expect(response).to redirect_to login_sessions_path
    end

    it 'can not be accessed by a client' do
      sign_in(client)
      get :designer_center
      expect(response).to redirect_to login_sessions_path
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
          expect(response).to redirect_to designer_center_contest_index_path
        end

        it 'redirects to responses list if the designer has active requests' do
          Fabricate(:contest_request, designer: designer, contest: Fabricate(:contest))
          get :designer_center
          expect(response).to redirect_to designer_center_response_index_path
        end
      end

    end
  end
end
