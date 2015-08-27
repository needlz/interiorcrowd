require 'rails_helper'

RSpec.describe CreditCardsController do



  context 'user is signed in' do
    let(:client) { Fabricate(:client) }
    let(:credit_card) { Fabricate(:credit_card) }

    def create_params
      { credit_card: credit_card.to_param }
    end

    before do
      sign_in(client)
    end

    it 'creates new credit card' do
      post :create, create_params

      expect(response).to be_ok
      expect(client.credit_cards).to eq([credit_card])
    end

    context 'if client hasn\'t already set primary card' do
      let(:credit_card) { Fabricate(:credit_card) }
      let(:client) { Fabricate(:client, credit_cards: [credit_card]) }

      it 'sets primary card for current client' do
        patch :set_as_primary, id: credit_card.id
        expect(response).to be_ok
      end
    end

    context 'if client has already set primary card' do
      let(:old_primary_card) {  Fabricate(:credit_card)}
      let(:new_primary_card) {  Fabricate(:credit_card)}
      let(:client) { Fabricate(:client,
                               credit_cards: [old_primary_card, new_primary_card],
                               primary_card: old_primary_card) }

      it 'sets primary card for current client' do
        expect(client.primary_card).to eq(old_primary_card)

        patch :set_as_primary, id: new_primary_card.id
        expect(response).to be_ok
      end

      it 'cannot set not existing card for current client' do
        expect{patch :set_as_primary, id: 0}.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end

  end

end
