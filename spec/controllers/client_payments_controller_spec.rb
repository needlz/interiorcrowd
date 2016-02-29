require 'rails_helper'
require 'spec_helper'

RSpec.describe ClientPaymentsController do
  render_views

  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:contest, client: client, status: 'brief_pending') }
  let(:credit_card) { Fabricate(:credit_card, client: client) }
  let(:promocode) { Fabricate(:promocode) }

  before do
    mock_stripe_customer_registration
  end

  describe 'POST create' do
    before do
      sign_in(client)
    end

    context 'when automatic payment enabled' do
      before do
        allow(Settings).to receive(:payment_enabled) { true }
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
              expect(Settings.payment_enabled).to be_truthy
              post :create, contest_id: contest.id, client_agree: 'yes'
              expect(contest.client_payment.last_error).to be_nil
              expect(response).to redirect_to(payment_summary_contests_path(id: contest.id))
            end

            it 'does not log any error' do
              expect(ErrorsLogger).to_not receive(:log)
              post :create, contest_id: contest.id, client_agree: 'yes'
            end

            it 'sets last_contest_created_at for client' do
              post :create, contest_id: contest.id, client_agree: 'yes'
              expect(client.reload.latest_contest_created_at).to be_within(5.seconds).of(Time.current)
            end

            context 'when contest brief is not completed' do
              before do
                allow_any_instance_of(SubmitContest).to receive(:brief_completed?) { false }
              end

              it 'does not send welcoming email to a client' do
                post :create, contest_id: contest.id, client_agree: 'yes'
                expect(jobs_with_handler_like('client_registered').count).to eq 0
              end

              it 'keeps in db that user was notified about a contest not yet live' do
                post :create, contest_id: contest.id, client_agree: 'yes'
                expect(contest.reload.notified_client_contest_not_yet_live).to be_truthy
              end
            end

            context 'when contest brief is completed' do
              before do
                allow_any_instance_of(SubmitContest).to receive(:brief_completed?) { true }
              end

              it 'sends welcoming email to a client' do
                expect(contest.status).to eq 'brief_pending'
                post :create, contest_id: contest.id, client_agree: 'yes'
                expect(jobs_with_handler_like('client_registered').count).to eq 1
              end

              it 'does not keep in db that user was notified about a contest not yet live' do
                post :create, contest_id: contest.id, client_agree: 'yes'
                expect(contest.reload.notified_client_contest_not_yet_live).to be_falsey
              end
            end

            context 'when owner already notified' do
              before do
                client.update_attributes!(notified_owner: true)
              end

              it 'does not notify product owner about new client' do
                post :create, contest_id: contest.id, client_agree: 'yes'
                expect(jobs_with_handler_like('client_registration_info').count).to eq 0
              end
            end

            context 'when owner not notified' do
              it 'notifies product owner about new client' do
                post :create, contest_id: contest.id, client_agree: 'yes'
                expect(jobs_with_handler_like('client_registration_info').count).to eq 1
                expect(client.reload.notified_owner).to be_truthy
              end
            end
          end

          context 'unsuccessful charge' do
            before do
              mock_stripe_unsuccessful_charge
            end

            it 'does not create payment' do
              expect(contest.promocodes.count).to eq(0)

              post :create, contest_id: contest.id, client: { promocode: promocode.promocode }, client_agree: 'yes'

              expect(response).to redirect_to(payment_details_contests_path(id: contest.id))
              expect(contest.client_payment.present?).to be_falsey
              expect(contest.promocodes.count).to eq(0)
              expect(contest.status).to eq('brief_pending')
            end

            it 'logs error' do
              expect(ErrorsLogger).to receive(:log)
              post :create, contest_id: contest.id, client_agree: 'yes'
            end

            it 'does not set contest_created_at for contests' do
              post :create, contest_id: contest.id, client_agree: 'yes'
              expect(client.reload.latest_contest_created_at).to be_nil
            end

            it 'does not send welcoming email to a client' do
              post :create, contest_id: contest.id, client_agree: 'yes'
              expect(jobs_with_handler_like('client_registered').count).to eq 0
            end
          end
        end

        context 'when client has no primary card' do
          before do
            mock_stripe_successful_charge
          end

          it 'does not create payment' do
            post :create, contest_id: contest.id, client: { promocode: promocode.promocode }, client_agree: 'yes'

            expect(response).to redirect_to(payment_details_contests_path(id: contest.id))
            expect(contest.client_payment.present?).to be_falsey
            expect(contest.promocodes.count).to eq(0)
            expect(contest.status).to eq('brief_pending')
          end
        end
      end

      context 'when credit card passed' do
        let(:params) { { contest_id: contest.id, credit_card: credit_card_attributes } }

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
            post :create, params.merge(client_agree: 'yes')
            expect(response).to redirect_to(payment_details_contests_path(id: contest.id))
            expect(contest.reload.client_payment).to be_nil
          end
        end

        context 'when client has no other cards' do
          context 'when contest not submitted yet' do
            it 'creates payment' do
              post :create, params.merge(client_agree: 'yes')
              expect(contest.client_payment.last_error).to be_nil
              expect(response).to redirect_to(payment_summary_contests_path(id: contest.id))
            end
          end
        end
      end
    end

    context 'when automatic payment disabled' do
      before do
        allow(Settings).to receive(:payment_enabled) { false }
      end

      context 'when credit card not passed' do
        context 'when client has primary card' do
          let(:params) { { contest_id: contest.id, client_agree: 'yes' } }

          before do
            client.update_attributes!(primary_card_id: credit_card.id)
          end

          it 'does not create payment' do
            expect(contest.client_payment).to be_falsey
            post :create, params
            expect(response).to redirect_to(payment_summary_contests_path(id: contest.id))
          end

          it 'does not log any error' do
            expect(ErrorsLogger).to_not receive(:log)
            post :create, params
          end

          it 'sets last_contest_created_at for client' do
            post :create, params
            expect(client.reload.latest_contest_created_at).to be_within(5.seconds).of(Time.current)
          end

          context 'when contest brief is not completed' do
            before do
              allow_any_instance_of(SubmitContest).to receive(:brief_completed?) { false }
            end

            it 'does not send welcoming email to a client' do
              post :create, params
              expect(jobs_with_handler_like('client_registered').count).to eq 0
            end

            it 'sends email about brief pending' do
              post :create, params
              expect(jobs_with_handler_like('new_client_no_photos').count).to eq 1
            end

            it 'keeps in db that user was notified about a contest not yet live' do
              post :create, params
              expect(contest.reload.notified_client_contest_not_yet_live).to be_truthy
            end
          end

          context 'when contest brief is completed' do
            before do
              allow_any_instance_of(SubmitContest).to receive(:brief_completed?) { true }
            end

            it 'sends welcoming email to a client' do
              expect(contest.status).to eq 'brief_pending'
              post :create, params
              expect(jobs_with_handler_like('client_registered').count).to eq 1
            end

            it 'does not keep in db that user was notified about a contest not yet live' do
              post :create, params
              expect(contest.reload.notified_client_contest_not_yet_live).to be_falsey
            end
          end

          context 'when owner already notified' do
            before do
              client.update_attributes!(notified_owner: true)
            end

            it 'does not notify product owner about new client' do
              post :create, params
              expect(jobs_with_handler_like('client_registration_info').count).to eq 0
            end
          end

          context 'when owner not notified' do
            it 'notifies product owner about new client' do
              post :create, params
              expect(jobs_with_handler_like('client_registration_info').count).to eq 1
              expect(client.reload.notified_owner).to be_truthy
            end
          end
        end

        context 'when client has no primary card' do
          before do
            mock_stripe_successful_charge
          end

          it 'does not create payment' do
            post :create, contest_id: contest.id, client: { promocode: promocode.promocode }, client_agree: 'yes'

            expect(response).to redirect_to(payment_details_contests_path(id: contest.id))
            expect(contest.client_payment).to be_nil
            expect(contest.promocodes.count).to eq(0)
            expect(contest.status).to eq('brief_pending')
          end

          it 'does not send welcoming email to a client' do
            post :create, contest_id: contest.id, client_agree: 'yes'
            expect(jobs_with_handler_like('client_registered').count).to eq 0
          end
        end
      end

      context 'when credit card passed' do
        let(:params) { { contest_id: contest.id, credit_card: credit_card_attributes, client_agree: 'yes' } }

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
            post :create, params
            expect(response).to redirect_to(payment_details_contests_path(id: contest.id))
            expect(contest.reload.client_payment).to be_nil
          end
        end

        context 'when client has no other cards' do
          context 'when contest not submitted yet' do
            it 'redirects to payment summary page' do
              post :create, params
              expect(response).to redirect_to(payment_summary_contests_path(id: contest.id))
            end
          end

          context 'when contest brief is not completed' do
            before do
              allow_any_instance_of(SubmitContest).to receive(:brief_completed?) { false }
            end

            it 'does not send welcoming email to a client' do
              post :create, params
              expect(jobs_with_handler_like('client_registered').count).to eq 0
            end

            it 'sends email about brief pending' do
              post :create, params
              expect(jobs_with_handler_like('new_client_no_photos').count).to eq 1
            end

            it 'keeps in db that user was notified about a contest not yet live' do
              post :create, params
              expect(contest.reload.notified_client_contest_not_yet_live).to be_truthy
            end

            it 'does not move contest to submission state' do
              post :create, params
              expect(contest.status).to eq 'brief_pending'
            end
          end

          context 'when contest brief is completed' do
            before do
              allow_any_instance_of(SubmitContest).to receive(:brief_completed?) { true }
            end

            it 'sends welcoming email to a client' do
              expect(contest.status).to eq 'brief_pending'
              post :create, params
              expect(jobs_with_handler_like('client_registered').count).to eq 1
            end

            it 'does not keep in db that user was notified about a contest not yet live' do
              post :create, params
              expect(contest.reload.notified_client_contest_not_yet_live).to be_falsey
            end

            it 'submits contest' do
              post :create, params
              expect(contest.reload.status).to eq 'submission'
            end

            it 'does not send email about brief pending' do
              post :create, params
              expect(jobs_with_handler_like('new_client_no_photos').count).to eq 0
            end
          end
        end
      end
    end
  end

end
