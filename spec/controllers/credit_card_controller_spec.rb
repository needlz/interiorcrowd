require 'rails_helper'

RSpec.describe CreditCardsController do

  context 'if client hasn\'t already set primary card' do
    let(:credit_card) {  Fabricate(:credit_card)}
    let(:client) { Fabricate(:client, credit_cards: [credit_card]) }

    before do
      sign_in(client)
    end

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
      sign_in(client)
      expect(client.primary_card).to eq(old_primary_card)

      patch :set_as_primary, id: new_primary_card.id
      expect(response).to be_ok
    end

    it 'cannot set not existing card for current client' do
      sign_in(client)

      expect{patch :set_as_primary, id: 263}.to raise_exception(ActiveRecord::RecordNotFound)
    end

  end
end
