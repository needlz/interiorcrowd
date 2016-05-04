require 'rails_helper'
require 'spec_helper'

RSpec.describe TimeTrackerController do
  render_views

  describe 'GET #time_tracker for client' do
    let(:client) { Fabricate(:client) }

    before do
      sign_in(client)
      contest
    end

    context 'when client is owner of the contest' do
      let(:time_tracker) { Fabricate(:time_tracker) }

      context 'when fulfillment status of contest' do
        let(:contest) { Fabricate(:contest_during_fulfillment, client: client, time_tracker: time_tracker) }

        it 'render time_tracker' do
          get :clients_show, id: contest.id

          expect(response).to render_template(:clients_show)
        end

        it 'has access to time tracker view' do
          get :clients_show, id: contest.id
          time_tracker_view = TimeTrackerView.new(time_tracker)
          expect(assigns(:time_tracker)).equal?(time_tracker_view)
        end
      end

      context 'when final_fulfillment status of contest' do
        let(:contest) { Fabricate(:contest_during_final_fulfillment,
                                                    client: client,
                                                    time_tracker: time_tracker) }

        context 'when there is designer activity tracked' do
          before do
            Fabricate(:designer_activity, time_tracker: time_tracker)
          end

          it 'render time_tracker' do
            get :clients_show, id: contest.id

            expect(response).to render_template(:clients_show)
          end
        end

        context 'when there is no designer activity tracked' do
          it 'render time_tracker' do
            get :clients_show, id: contest.id

            expect(response).to render_template(:clients_show)
          end
        end

        it 'has access to time tracker view' do
          get :clients_show, id: contest.id
          time_tracker_view = TimeTrackerView.new(time_tracker)
          expect(assigns(:time_tracker)).equal?(time_tracker_view)
        end
      end

      context 'when submission status of contest' do
        let(:contest) { Fabricate(:contest_in_submission, client: client) }

        it 'it response with 404' do
          get :clients_show, id: contest.id
          expect(response).to have_http_status(404)
        end
      end

      context 'when winner selection status of contest' do
        let(:contest) { Fabricate(:contest_during_winner_selection, client: client) }

        it 'it response with 404' do
          get :clients_show, id: contest.id
          expect(response).to have_http_status(404)
        end
      end
    end

    context 'when client is not the owner of the contest' do
      let(:owner) { Fabricate(:client) }
      let(:time_tracker) { Fabricate(:time_tracker) }
      let(:contest) { Fabricate(:contest_during_fulfillment, client: owner, time_tracker: time_tracker) }
      let(:final_fulfillment_contest) { Fabricate(:contest_during_final_fulfillment,
                                                  client: owner,
                                                  time_tracker: time_tracker) }

      it 'it respond with 404' do
        get :clients_show, id: contest.id
        expect(response).to have_http_status(404)
      end
    end
  end


  describe 'GET #time_tracker for designer' do
    let(:designer) { Fabricate(:designer) }
    let(:contest_request) { Fabricate(:contest_request, designer: designer, contest: contest) }

    context 'when designer is not the participant of the contest' do
      let(:foreign_designer) { Fabricate(:designer) }
      let(:contest) { Fabricate(:contest_during_winner_selection) }

      before do
        sign_in(foreign_designer)
        SelectWinner.perform(contest_request)
      end

      it 'it response with 404' do
        get :designers_show, contest_id: contest.id

        expect(response).to have_http_status(404)
      end

    end

    context 'when designer is not the winner of the contest' do
      let(:loser_designer) { Fabricate(:designer) }
      let(:loser_contest_request) { Fabricate(:contest_request, designer: loser_designer, answer: 'no', contest: contest) }
      let(:contest) { Fabricate(:contest_during_winner_selection,
                                time_tracker: time_tracker) }
      let(:time_tracker) { Fabricate(:time_tracker) }

      before do
        sign_in(loser_designer)
        loser_contest_request
      end

      it 'it response with 404' do
        get :designers_show, contest_id: contest.id

        expect(response).to have_http_status(404)
      end
    end

    context 'when designer is the winner of the contest' do
      let(:contest) { Fabricate(:contest_during_winner_selection) }
      let(:contest_request) { Fabricate(:contest_request, designer: designer, answer: 'winner', contest: contest) }

      before do
        sign_in(designer)
        SelectWinner.perform(contest_request)
      end

      it 'render time_tracker' do
        get :designers_show, contest_id: contest.id

        expect(response).to render_template(:designers_show)
      end
    end
  end

  describe 'POST #suggest_hours' do
    let(:designer) { Fabricate(:designer) }
    let(:contest) { Fabricate(:contest_during_winner_selection) }
    let(:contest_request) { Fabricate(:contest_request, designer: designer, answer: 'winner', contest: contest) }

    context 'when contest owner is trying to suggest hours' do
      let(:client) { Fabricate(:client) }

      before do
        sign_in(client)
        SelectWinner.perform(contest_request)
      end

      it 'redirects to designer sign in path' do
        expect(post :suggest_hours, contest_id: contest.id, suggested_hours: 10).to redirect_to designer_login_sessions_path
      end

    end

    context 'when designer is not the participant of the contest' do
      let(:not_the_participant) { Fabricate(:designer) }

      before do
        sign_in(not_the_participant)
        SelectWinner.perform(contest_request)
      end

      it 'renders 404' do

        expect(post :suggest_hours, contest_id: contest.id, suggested_hours: 10).to have_http_status(:not_found)
      end
    end

    context 'when designer is participant of the contest' do

      before do
        sign_in(designer)
        SelectWinner.perform(contest_request)
      end

      context 'when no hours amount is submitted' do
        it 'answers with server error message' do
          post :suggest_hours, contest_id: contest.id
          expect(response).to have_http_status(500)
        end
      end

      context 'designer is adding positive amount of hours' do
        it 'updates the amount of hours suggested' do
          post :suggest_hours, contest_id: contest.id, suggested_hours: 10
          expect(response).to have_http_status(200)
        end
      end

      context 'designer is adding negative amount of hours' do
        it 'answers with server error message' do
          post :suggest_hours, contest_id: contest.id, suggested_hours: -10
          expect(response).to have_http_status(500)
        end
      end
    end
  end

  describe 'POST #purchase_confirm' do
    let(:contest) { Fabricate(:contest_during_fulfillment, time_tracker: time_tracker) }
    let(:time_tracker) { Fabricate(:time_tracker) }

    context 'when designer is trying to buy hours' do
      let(:designer) { Fabricate(:designer) }

      before do
        sign_in(designer)
      end

      it 'redirects to client sign in path' do
        expect(post :purchase_confirm, id: contest.id, hours: 10).to redirect_to client_login_sessions_path
      end
    end

    context 'when client is trying to buy hours' do
      let(:client) { Fabricate(:client) }

      before do
        sign_in(client)
      end

      context 'when client is not contest owner' do
        it 'renders 404' do
          expect(post :purchase_confirm, id: contest.id, hours: 10).to have_http_status(:not_found)
        end
      end

      context 'when client is contest owner' do
        let(:client) { Fabricate(:client) }
        let(:contest) { Fabricate(:contest_during_fulfillment, time_tracker: time_tracker, client: client) }

        it 'renders page' do
          post :purchase_confirm, id: contest.id, hours: 10
          expect(response).to have_http_status(:ok)
        end
      end
    end

  end

  describe 'POST #show_invoice' do
    let(:contest) { Fabricate(:contest_during_fulfillment, time_tracker: time_tracker) }
    let(:time_tracker) { Fabricate(:time_tracker) }

    context 'when designer is trying to buy hours' do
      let(:designer) { Fabricate(:designer) }

      before do
        sign_in(designer)
      end

      it 'redirects to client sign in path' do
        expect(post :show_invoice, id: contest.id, hours: 10).to redirect_to client_login_sessions_path
      end
    end

    context 'when client is trying to buy hours' do
      let(:credit_card) { Fabricate(:credit_card) }
      let(:client) { Fabricate(:client, credit_cards: [credit_card], primary_card: credit_card) }

      before do
        sign_in(client)
        mock_stripe_customer_registration
        mock_stripe_successful_charge
      end

      context 'when client is not contest owner' do
        it 'renders 404' do
          expect(post :show_invoice, id: contest.id, hours: 10).to have_http_status(:not_found)
        end
      end

      context 'when client is contest owner' do
        let(:contest) { Fabricate(:contest_during_fulfillment, time_tracker: time_tracker, client: client) }

        it 'renders page' do
          post :show_invoice, id: contest.id, hours: 10
          expect(response).to render_template(:show_invoice)
        end

        it 'updates the actual hours count' do
          post :show_invoice, id: contest.id, hours: 10
          expect(contest.time_tracker.reload.hours_actual).to eq(10)
          expect(contest.time_tracker.reload.hours_suggested).to eq(0)
        end

        it 'creates hourly payment' do
          expect(contest.time_tracker.hourly_payments).to be_empty

          post :show_invoice, id: contest.id, hours: 10

          expect(contest.time_tracker.hourly_payments).to be_present
        end

        it 'performs Stripe payment successfully' do
          post :show_invoice, id: contest.id, hours: 10

          expect(contest.time_tracker.hourly_payments.last.payment_status).to eq('completed')
        end
      end
    end

  end
end
