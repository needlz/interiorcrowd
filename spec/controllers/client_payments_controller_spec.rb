require 'rails_helper'
require 'spec_helper'

RSpec.describe ClientPaymentsController do
  render_views

  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:contest, client: client) }
  let(:credit_card) { Fabricate(:credit_card, client: client) }
  let(:promocode) { Fabricate(:promocode) }

  before do
    mock_stripe_customer_registration
  end

  describe 'POST create' do
    before do
      sign_in(client)
    end

    context 'when credit card not passed' do
      context 'when client has primary card' do
        before do
          client.update_attributes!(primary_card_id: credit_card.id)
        end

        context 'successful charge' do
          before do
            mock_stripe_successful_charge
          end

          it 'creates payment' do
            post :create, contest_id: contest.id
            expect(contest.client_payment.last_error).to be_nil
            expect(response).to redirect_to(payment_summary_contests_path(id: contest.id))
          end

          it 'does not log any error' do
            expect(ErrorsLogger).to_not receive(:log)
            post :create, contest_id: contest.id
          end
        end

        context 'unsuccessful charge' do
          before do
            mock_stripe_unsuccessful_charge
          end

          it 'does not create payment' do
            expect(contest.promocodes.count).to eq(0)

            post :create, contest_id: contest.id, client: { promocode: promocode.promocode}

            expect(response).to redirect_to(payment_details_contests_path(id: contest.id))
            expect(contest.client_payment.present?).to be_falsey
            expect(contest.promocodes.count).to eq(0)
            expect(contest.status).to eq('brief_pending')
          end

          it 'logs error' do
            expect(ErrorsLogger).to receive(:log)
            post :create, contest_id: contest.id
          end
        end
      end

      context 'when client has no primary card' do
        before do
          mock_stripe_successful_charge
        end

        it 'does not create payment' do
          post :create, contest_id: contest.id, client: { promocode: promocode.promocode}

          expect(response).to redirect_to(payment_details_contests_path(id: contest.id))
          expect(contest.client_payment.present?).to be_falsey
          expect(contest.promocodes.count).to eq(0)
          expect(contest.status).to eq('brief_pending')
        end
      end
    end

    context 'when credit card passed' do
      before do
        mock_stripe_successful_charge
        mock_stripe_customer_registration
        mock_stripe_card_adding
        mock_stripe_setting_default_card
      end

      context 'when client has other cards' do
        before do
          credit_card
        end

        it 'does not create payment' do
          post :create, contest_id: contest.id, credit_card: credit_card_attributes
          expect(response).to redirect_to(payment_details_contests_path(id: contest.id))
          expect(contest.reload.client_payment).to be_nil
        end
      end

      context 'when client has no other cards' do
        context 'when contest not submitted yet' do
          it 'creates payment' do
            post :create, contest_id: contest.id, credit_card: credit_card_attributes
            expect(contest.client_payment.last_error).to be_nil
            expect(response).to redirect_to(payment_summary_contests_path(id: contest.id))
          end
        end

        context 'when contest submitted' do
          before do
            contest.update_attributes!(status: 'submission')
          end

          it 'creates payment' do
            post :create, contest_id: contest.id, credit_card: credit_card_attributes
            expect(contest.client_payment.last_error).to be_nil
            expect(response).to redirect_to(payment_summary_contests_path(id: contest.id))
          end
        end
      end
    end
  end

end
