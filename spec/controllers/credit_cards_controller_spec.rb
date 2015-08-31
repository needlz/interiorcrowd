require 'rails_helper'

RSpec.describe CreditCardsController do



  context 'user is signed in' do
    let(:client) { Fabricate(:client) }
    let(:credit_card) { Fabricate(:credit_card) }

    def create_params
      { credit_card: {zip: credit_card.zip,
                     number: credit_card.number,
                     cvc: credit_card.cvc,
                     ex_month: credit_card.ex_month,
                     ex_year: credit_card.ex_year} }
    end

    before do
      sign_in(client)
    end

    it 'creates new credit card' do
      expect{post :create, create_params}.to change{client.credit_cards.count}.by(1)
      expect(response).to be_ok
      expect(client.credit_cards.first.number).to eq(credit_card.number.to_s)
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
      let(:old_primary_card) { Fabricate(:credit_card) }
      let(:new_primary_card) { Fabricate(:credit_card) }
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
