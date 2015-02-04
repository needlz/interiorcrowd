require 'rails_helper'

RSpec.describe BetaSubscribersController do
  render_views

  def subscriber_params(options = {})
    { beta_subscriber: { name: 'name', email: 'email@email', role: 'designer' } }.deep_merge(options)
  end

  describe 'POST create' do
    context 'proper params' do
      it 'creates beta subscriber' do
        post :create, subscriber_params
        expect(BetaSubscriber.count).to eq 1
      end

      it 'renders beta signup page' do
        post :create, subscriber_params
        expect(response).to render_template(:sign_up_beta)
      end
    end
  end
end
