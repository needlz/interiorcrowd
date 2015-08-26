require 'rails_helper'

RSpec.describe Payment do

  let(:client) { Fabricate(:client) }
  let(:promocode) { Fabricate(:promocode, discount_cents: 2000) }
  let(:contest) { Fabricate(:contest, client: client, promocodes: [promocode]) }

  context 'when successful charge' do
    before do
      allow_any_instance_of(StripeCustomer).to receive(:charge) do
        Hashie::Mash.new(id: 'charge_id')
      end
    end

    it 'creates client_payment' do
      Payment.new(contest).perform
      expect(contest.client_payment.client_id).to eq(client.id)
      expect(contest.client_payment.amount_cents).to eq(contest.package.price_in_cents - promocode.discount_cents)
      expect(contest.client_payment.promotion_cents).to eq(promocode.discount_cents)
      expect(contest.client_payment.last_error).to be_blank
      expect(contest.client_payment.payment_status).to eq('completed')
    end
  end

end
