require 'rails_helper'

RSpec.describe ChargeHourlyPayment do
  let(:credit_card) { Fabricate(:credit_card) }
  let(:client) { Fabricate(:client, primary_card_id: credit_card.id) }
  let(:contest) { Fabricate(:contest_during_fulfillment, client: client) }
  let(:designer) { Fabricate(:designer) }
  let!(:winner_request) do
    contest_request = Fabricate(:contest_request, contest: contest, status: 'fulfillment_ready', designer: designer)
    contest_request.update_attribute(:answer, 'winner')
    contest_request
  end
  let!(:time_tracker) { Fabricate(:time_tracker, contest: contest) }
  let!(:hours_count) { 4 }

  before do
    mock_stripe_customer_registration
  end

  context 'when Stripe payment is successful' do
    before do
      mock_stripe_successful_charge
    end

    it 'creates hourly payment' do
      ChargeHourlyPayment.new(contest, hours_count).perform

      stored_payment = time_tracker.hourly_payments.last

      expect(stored_payment.client_id).to eq(client.id)
      expect(stored_payment.total_price_in_cents).to eq(Settings.hour_with_designer_price * hours_count * 100)
      expect(stored_payment.hours_count).to eq(hours_count)
      expect(stored_payment.last_error).to be_blank
      expect(stored_payment.payment_status).to eq('completed')
      expect(stored_payment.credit_card_id).to eq(credit_card.id)
    end
  end

  context 'when stripe error occured' do
    before do
      mock_stripe_unsuccessful_charge
    end

    it 'creates hourly payment with error set and failed payment status' do
      payment = ChargeHourlyPayment.new(contest, hours_count)
      expect { payment.perform }.to raise_error(Stripe::StripeError)
      expect(time_tracker.hours_actual).to eq 0
      expect(time_tracker.hourly_payments.last.last_error).to be_present
      expect(time_tracker.hourly_payments.last.payment_status).to eq('failed')
      expect(time_tracker.hourly_payments.last.stripe_charge_id).to be_nil
    end
  end

  context 'client has no primary card' do
    before do
      client.update_attributes!(primary_card_id: nil)
    end

    it 'does not create hourly payment' do
      payment = ChargeHourlyPayment.new(contest, hours_count)
      expect{ payment.perform }.to raise_error(ArgumentError)
      expect(time_tracker.hourly_payments).to be_empty
    end
  end
end
