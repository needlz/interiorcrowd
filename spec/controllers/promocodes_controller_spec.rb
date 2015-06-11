require 'rails_helper'

RSpec.describe PromocodesController do
  render_views

  let(:profit) { 'some profit' }
  let(:code) { Fabricate(:promocode, profit: profit) }
  let(:valid_token) { code.token }
  let(:invalid_token) { '1111' }

  describe 'GET apply' do
    def test_code
      get :apply, code: token
      JSON.parse(response.body)
    end

    context 'valid token' do
      let(:token) { valid_token }

      it 'returns true' do
        json = test_code
        expect(json['valid']).to be_truthy
      end

      it 'returns profit' do
        json = test_code
        expect(json['profit']).to eq profit
      end
    end

    context 'invalid token' do
      let(:token) { invalid_token }

      it 'returns false' do
        json = test_code
        expect(json['valid']).to be_falsey
      end
    end
  end

end
