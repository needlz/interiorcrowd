require 'rails_helper'

RSpec.describe Payment do

  let(:credit_card) { Fabricate(:credit_card) }
  let(:client) { Fabricate(:client, primary_card_id: credit_card.id) }
  let(:promocode) { Fabricate(:promocode, discount_cents: 2000) }
  let(:contest) { Fabricate(:contest, client: client, promocodes: [promocode]) }

  before do
    mock_stripe_customer_registration
  end

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

  context 'when stripe error occured' do
    before do
      mock_stripe_unsuccessful_charge
    end

    it 'creates client payment and set last_error attribute' do
      payment = Payment.new(contest)
      payment.perform
      expect(payment.client_payment.last_error).to be_present
      expect(payment.client_payment.payment_status).to eq 'pending'
    end
  end

  context 'client has no primary card' do
    before do
      client.update_attributes!(primary_card_id: nil)
    end

    it 'does not create client payment' do
      payment = Payment.new(contest)
      payment.perform
      expect(contest.client_payment).to be_nil
      expect(payment.exception).to be_kind_of(ArgumentError)
    end
  end



end
