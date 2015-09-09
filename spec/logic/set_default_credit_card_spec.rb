require 'rails_helper'

RSpec.describe SetDefaultCreditCard do
  let(:credit_card) { Fabricate(:credit_card) }
  let(:client) { Fabricate(:client, credit_cards: [credit_card]) }

  context 'passing valid credit card id' do
    it 'sets the new primary credit card for client' do
      allow_any_instance_of(StripeCustomer).to receive(:set_default) do
        Hashie::Mash.new(stripe_customer_id: 'id')
      end

      set_primary_card = SetDefaultCreditCard.new(client: client, card_id: credit_card.id)
      set_primary_card.perform

      expect(set_primary_card.saved?).to be_truthy

      client.reload

      expect(client.primary_card).to eq(credit_card)
    end
  end

  context 'passing bad credit card id' do
    it 'doesn\'t set new primary card for client' do
      allow_any_instance_of(StripeCustomer).to receive(:set_default) do
        Hashie::Mash.new(stripe_customer_id: 'id')
      end

      set_primary_card = SetDefaultCreditCard.new(client: client, card_id: 0)
      set_primary_card.perform

      expect(set_primary_card.saved?).to be_falsey
      expect(client.primary_card).to be_nil
    end
  end
end
