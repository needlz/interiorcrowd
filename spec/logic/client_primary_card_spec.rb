require 'rails_helper'

RSpec.describe ClientPrimaryCard do
  let(:client) { Fabricate(:client) }
  let(:credit_card) { Fabricate(:credit_card) }

  context 'passing valid credit card id' do
    it 'sets the new primary credit card for client' do
      client_primary_card = ClientPrimaryCard.new(client)

      expect(client_primary_card.set(credit_card.id)[:json]).to be_nil
      expect(client_primary_card.set(credit_card.id)[:status]).to eq(:ok)

      client.reload

      expect(client.primary_card).to eq(credit_card)
    end
  end

  context 'passing bad credit card id' do
    it 'doesn\'t set new primary card for client' do
      client_primary_card = ClientPrimaryCard.new(client)

      expect{client_primary_card.set(295)}.to raise_exception(ActiveRecord::RecordNotFound)
      expect(client.primary_card).to be_nil
    end
  end
end
