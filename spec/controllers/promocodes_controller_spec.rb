require 'rails_helper'

RSpec.describe PromocodesController do
  render_views

  let(:profit) { 'some profit %{discount_dollars}' }
  let(:code) { Fabricate(:promocode, display_message: profit) }
  let(:valid_token) { code.promocode }
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

      it 'interpolates discount price in display message' do
        json = test_code
        expect(json['display_message']).to eq "some profit #{ RenderingHelper.new.humanized_money_with_symbol(code.discount) }"
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
