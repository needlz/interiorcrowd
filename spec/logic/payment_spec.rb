require 'rails_helper'

RSpec.describe Payment do

  let(:credit_card) { Fabricate(:credit_card) }
  let(:client) { Fabricate(:client, primary_card_id: credit_card.id) }
  let(:promocode) { Fabricate(:promocode, discount_cents: 2000) }
  let(:contest) { Fabricate(:contest, client: client, promocodes: [promocode]) }

  context 'when successful charge' do
    before do
      mock_stripe_successful_charge
    end

    it 'creates client_payment' do
      Payment.new(contest).perform
      contest.reload
      expect(contest.client_payment.client_id).to eq(client.id)
      expect(contest.client_payment.amount_cents).to eq(contest.package.price_in_cents - promocode.discount_cents)
      expect(contest.client_payment.promotion_cents).to eq(promocode.discount_cents)
      expect(contest.client_payment.last_error).to be_blank
      expect(contest.client_payment.payment_status).to eq('completed')
      expect(contest.client_payment.credit_card_id).to eq(credit_card.id)
    end
  end

end
