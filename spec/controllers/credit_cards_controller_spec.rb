require 'rails_helper'

RSpec.describe CreditCardsController do

  context 'user is signed in' do
    let(:client) { Fabricate(:client) }
    let(:credit_card) { Fabricate(:credit_card) }
    let(:card_number) { '4242424242424242' }

    def create_params
      { credit_card: {zip: credit_card.zip,
                     number: card_number,
                     cvc: credit_card.cvc,
                     ex_month: credit_card.ex_month,
                     ex_year: credit_card.ex_year} }
    end

    before do
      sign_in(client)
    end

    it 'doesn\'t create new credit card when passing bad card info' do
      mock_stripe_card_adding

      card_params = create_params
      card_params[:credit_card].merge!(zip: 111)
      expect{ post :create, card_params }.to change{ client.credit_cards.count }.by(0)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(client.credit_cards.empty?).to be_truthy
    end

    it 'creates new credit card' do
      mock_stripe_customer_authentication
      mock_stripe_card_adding

      expect{ post :create, create_params }.to change{ client.credit_cards.count }.by(1)
      expect(response).to render_template('contests/_card_view')
      expect(client.credit_cards.first.last_4_digits.to_s).to eq(card_number.last(4))
      expect(client.reload.primary_card.last_4_digits.to_s).to eq(card_number.last(4))
    end

    it 'set newly created card as primary' do
      mock_stripe_customer_authentication
      mock_stripe_card_adding

      client.credit_cards << credit_card
      client.primary_card = client.credit_cards.first
      client.save!
      post :create, create_params
      expect(client.reload.primary_card.last_4_digits.to_s).to eq(card_number.last(4))
    end

    context 'if current client hasn\'t already set primary card' do
      let(:credit_card) { Fabricate(:credit_card) }
      let(:client) { Fabricate(:client, credit_cards: [credit_card]) }

      it 'sets primary card for current client' do
        mock_stripe_setting_default_card

        patch :set_as_primary, id: credit_card.id
        expect(response).to be_ok
      end
    end

    context 'if client has already set primary card' do
      let(:old_primary_card) { Fabricate(:credit_card) }
      let(:new_primary_card) { Fabricate(:credit_card) }
      let(:client) { Fabricate(:client,
                               credit_cards: [old_primary_card, new_primary_card],
                               primary_card: old_primary_card) }

      it 'sets primary card for current client' do
        expect(client.primary_card).to eq(old_primary_card)

        mock_stripe_setting_default_card

        patch :set_as_primary, id: new_primary_card.id
        expect(response).to be_ok
      end

      it 'cannot set not existing card for current client' do

        mock_stripe_setting_default_card

        patch :set_as_primary, id: 0
        expect(response).to have_http_status(:not_found)
      end
    end

    it 'deletes the credit card' do

      mock_stripe_card_deleting

      client.credit_cards << credit_card

      delete :destroy, id: credit_card.id
      expect(response).to be_ok

      client.reload

      expect(client.credit_cards.empty?).to be_truthy
    end

    it 'returns error when client wants to delete credit card with bad id' do
      mock_stripe_card_deleting

      delete :destroy, id: 0
      expect(response).to have_http_status(:not_found)
    end

    it 'can be edited' do
      client.credit_cards << credit_card
      get :edit, id: credit_card.id
      expect(response).to render_template('contests/_card_form')
    end

    it 'cannot be edited when user specified wrong id' do
      client.credit_cards << credit_card
      get :edit, id: 0
      expect(response).to have_http_status(:not_found)
    end

    it 'can be updated' do
      client.credit_cards << credit_card

      mock_stripe_card_updating

      patch :update, create_params.merge(id: credit_card.id)
      expect(response).to render_template('contests/_card_view')
    end

    it 'cannot be updated when specified wrong card details' do
      client.credit_cards << credit_card

      mock_stripe_card_updating

      patch :update, create_params.merge(id: credit_card.id, credit_card: { zip: 4444 })
      expect(response).to have_http_status(:unprocessable_entity)
    end

  end

end
