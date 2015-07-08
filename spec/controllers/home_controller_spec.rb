require 'rails_helper'

RSpec.describe HomeController do
  render_views

  context 'main subdomain' do
    before do
      request.host = 'www.interiorcrowd.com'
    end

    describe 'GET index' do
      context 'logged in as client' do
        before do
          sign_in(Fabricate(:client))
        end

        it 'renders page' do
          get :index
          expect(response).to render_template(:index)
        end
      end

      context 'logged in as designer' do
        before do
          sign_in(Fabricate(:designer))
        end

        it 'renders page' do
          get :index
          expect(response).to render_template(:index)
        end
      end

      context 'not logged in' do
        it 'renders page' do
          get :index
          expect(response).to render_template(:index)
        end
      end
    end

    it 'renders sign_up_beta page' do
      get :sign_up_beta
      expect(response).to render_template(:sign_up_beta)
    end

    it 'has no sign_in_beta page' do
      pending

      get :sign_in_beta
      expect(response).to have_http_status(:not_found)
    end
  end

  context 'beta subdomain' do
    before do
      request.host = 'beta.interiorcrowd.com'
    end

    describe 'GET sign_up_beta' do
      it 'renders page' do
        pending

        get :sign_up_beta
        expect(response).to have_http_status(:not_found)
      end
    end

    describe 'GET sign_in_beta' do
      it 'renders page' do
        get :sign_in_beta
        expect(response).to render_template(:sign_in_beta)
      end
    end
  end

  describe 'GET coming_soon' do
    it 'returns page' do
      get :coming_soon
      expect(response).to render_template(:coming_soon)
    end

    it 'knows return url' do
      get :sign_in_beta
      get :coming_soon
      expect(response).to render_template(:coming_soon)
    end
  end

  describe 'GET privacy_policy' do
    it 'returns page' do
      get :privacy_policy
      expect(response).to render_template(:privacy_policy)
    end
  end

  describe 'GET terms_of_service' do
    it 'returns page' do
      get :terms_of_service
      expect(response).to render_template(:terms_of_service)
    end
  end

end

