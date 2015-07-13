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
  end

  describe 'GET coming_soon' do
    it 'returns page' do
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

