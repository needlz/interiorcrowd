require 'rails_helper'
require 'spec_helper'

RSpec.describe ClientPaymentsController do
  render_views

  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:contest, client: client) }
  let(:credit_card) { Fabricate(:credit_card, client: client) }

  describe 'POST create' do
    before do
      sign_in(client)
      client.update_attributes!(primary_card_id: credit_card.id)
    end

    context 'valid contest id' do
      context 'successful charge' do
        before do
          mock_stripe_successful_charge
        end

        it 'creates payment' do
          post :create, contest_id: contest.id
          expect(contest.client_payment.last_error).to be_nil
          expect(response).to redirect_to(payment_summary_contests_path(id: contest.id))
        end
      end

      context 'unsuccessful charge' do
        before do
          mock_stripe_unsuccessful_charge
        end

        it 'does not create payment' do
          post :create, contest_id: contest.id
          expect(response).to redirect_to(payment_details_contests_path(id: contest.id))
          expect(contest.client_payment.last_error).to be_present
        end
      end
    end

    context 'invalid context id' do

    end
  end

end
