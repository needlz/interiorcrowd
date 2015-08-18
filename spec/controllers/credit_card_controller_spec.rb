require 'rails_helper'

RSpec.describe CreditCardsController do

  context 'if client hasn\'t already set primary card' do
    let(:client) { Fabricate(:client) }
    let(:credit_card) {  Fabricate(:credit_card)}

    it 'sets primary card for current client' do
      sign_in(client)

      patch :set_as_primary, id: credit_card.id
      client.reload
      expect(client.primary_card).to eq(credit_card)
    end

  end

  context 'if client has already set primary card' do
    let(:old_primary_card) {  Fabricate(:credit_card)}
    let(:client) { Fabricate(:client, primary_card: old_primary_card) }
    let(:new_primary_card) {  Fabricate(:credit_card)}


    it 'sets primary card for current client' do
      sign_in(client)
      expect(client.primary_card).to eq(old_primary_card)

      patch :set_as_primary, id: new_primary_card.id
      client.reload
      expect(client.primary_card).to eq(new_primary_card)
    end

    it 'cannot set not existing card for current client' do
      sign_in(client)

      expect{patch :set_as_primary, id: 263}.to raise_exception(ActiveRecord::RecordNotFound)
    end

  end
end
