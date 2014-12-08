require 'rails_helper'
require 'spec_helper'

RSpec.describe DesignerCenterController do
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

      it 'redirects to portfolio editing if portfolio exists' do
        Fabricate(:portfolio, designer: designer)
        get :designer_center
        expect(response).to redirect_to edit_portfolio_path
      end

      it 'redirects to portfolio creation if portfolio exists' do
        get :designer_center
        expect(response).to redirect_to new_portfolio_path
      end
    end
  end
end
