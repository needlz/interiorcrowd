require 'rails_helper'

RSpec.describe HomeController do
  render_views

  let(:client) { Fabricate(:client) }

  context 'when logged as client' do
    before do
      sign_in(client)
    end

    it 'tracks last activity time' do
      get :index
      expect(client.reload.last_activity_at).to be_within(2.seconds).of(Time.now)
    end
  end

  context 'main subdomain' do
    before do
      request.host = 'www.interiorcrowd.com'
    end

    describe 'GET index' do
      context 'logged in as client' do
        before do
          sign_in(client)
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

  describe 'GET about_us' do
    it 'returns page' do
      get :about_us
      expect(response).to render_template(:about_us)
    end
  end

  describe 'GET designer_submission' do
    it 'renders page' do
      get :designer_submission
      expect(response).to render_template(:designer_submission)
      expect(response).to have_http_status(:ok)
    end
  end

end

