require 'rails_helper'

RSpec.describe Payment do

  let(:credit_card) { Fabricate(:credit_card) }
  let(:client) { Fabricate(:client, primary_card_id: credit_card.id) }
  let(:promocode) { Fabricate(:promocode, discount_cents: 2000) }
  let(:contest) { Fabricate(:completed_contest, client: client, promocodes: [promocode], status: 'brief_pending') }

  before do
    mock_stripe_customer_registration
  end

  context 'when package is free' do
    let(:promocode) { Fabricate(:promocode, discount_cents: BudgetPlan::PLANS[0].price_in_cents) }

    it 'creates client_payment' do
      expect_any_instance_of(StripeCustomer).to_not receive(:charge)
      mock_stripe_successful_charge
      Payment.new(contest).perform
      contest.reload

      expect(contest.client_payment.client_id).to eq(client.id)
      expect(contest.client_payment.amount_cents).to eq(contest.package.price_in_cents - promocode.discount_cents)
      expect(contest.client_payment.promotion_cents).to eq(promocode.discount_cents)
      expect(contest.client_payment.last_error).to be_blank
      expect(contest.client_payment.payment_status).to eq('completed')
      expect(contest.client_payment.credit_card_id).to eq(credit_card.id)
      expect(contest.client_payment.stripe_charge_id).to eq(Payment::ZERO_PRICE_PLACEHOLDER)
    end
  end

  context 'when package is not free' do
    it 'creates client_payment' do
      expect_any_instance_of(StripeCustomer).to receive(:charge)
      mock_stripe_successful_charge
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

    it 'does not create client payment and does not change contest status' do
      payment = Payment.new(contest)
      expect { payment.perform }.to raise_error(Stripe::StripeError)
      expect(contest.client_payment.present?).to be_falsey
      expect(contest.status).to eq 'brief_pending'
    end
  end

  context 'client has no primary card' do
    before do
      client.update_attributes!(primary_card_id: nil)
    end

    it 'does not create client payment and does not change contest status' do
      payment = Payment.new(contest)
      expect{payment.perform}.to raise_error(ArgumentError)
      expect(contest.client_payment).to be_nil
      expect(contest.status).to eq 'brief_pending'
    end
  end

end
