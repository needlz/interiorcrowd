require 'rails_helper'

RSpec.describe ClientPrimaryCard do
  let(:credit_card) { Fabricate(:credit_card) }
  let(:client) { Fabricate(:client, credit_cards: [credit_card]) }

  context 'passing valid credit card id' do
    it 'sets the new primary credit card for client' do
      client_primary_card = ClientPrimaryCard.new(client)
      client_primary_card.set(credit_card.id)

      expect(client_primary_card.saved?).to be_truthy

      client.reload

      expect(client.primary_card).to eq(credit_card)
    end
  end

  context 'passing bad credit card id' do
    it 'doesn\'t set new primary card for client' do
      client_primary_card = ClientPrimaryCard.new(client)
      client_primary_card.set(0)

      expect(client_primary_card.saved?).to be_falsey
      expect(client.primary_card).to be_nil
    end
  end
end
