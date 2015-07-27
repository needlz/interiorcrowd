require 'rails_helper'
require 'spec_helper'

RSpec.describe ClientsController do
  render_views

  include ClientsHelper

  let(:client) { Fabricate(:client) }
  let(:appeals) do
    (0..2).map do |index|
      Appeal.create!(first_name: "first_name#{ index }", second_name: "second_name#{ index }")
    end
  end
  let(:default_password) { 'password' }
  let(:promocode) { Fabricate(:promocode) }
  let(:client_options){
    { password: default_password,
      password_confirmation: default_password,
      first_name: 'firstname',
      last_name: 'lastname',
      email: 'email@example.com',
      address: 'address',
      name_on_card: 'name_on_card',
      card_type: 'Visa',
      city: 'City',
      state: 'state',
      card_ex_month: '12',
      card_ex_year: Time.current.year + 5,
      card_cvc: '123',
      zip: '81100',
      promocode: promocode.promocode
    }
  }
  let(:integer_attributes) { [:zip, :card_ex_month, :card_ex_year, :card_cvc] }

  describe 'POST create' do
    it 'creates contest and client' do
      expect(Contest.count).to eq 0
      expect(Client.count).to eq 0
      post :create, { client: client_options }, contest_options_source
      expect(Contest.count).to eq 1
      expect(Client.count).to eq 1
    end

    it 'does not create contest if some of required options were not set' do
      expect(Contest.count).to eq 0
      expect(Client.count).to eq 0
      expect { post :create, { client: client_options }, contest_options_source.except(:design_brief) }.to raise_error
      expect(Contest.count).to eq 0
      expect(Client.count).to eq 1
    end

    it 'redirects to entries page' do
      post :create, { client: client_options }, contest_options_source
      expect(response).to redirect_to(entries_client_center_index_path({signed_up: true}) )
    end

    it 'saves attributes' do
      post :create, { client: client_options }, contest_options_source
      client = Client.order(:created_at).last
      client_options.except(:password, :password_confirmation, :promocode, *integer_attributes).each do |attribute, value|
        expect(client.send(attribute)).to eq value
      end
      integer_attributes.each do |attribute|
        expect(client.send(attribute)).to eq client_options[attribute].to_i
      end
      expect(client.designer_level_id).to eq contest_options_source[:design_style][:designer_level]
      expect(client.plain_password).to eq client_options[:password]
    end

    it 'creates mail job' do
      post :create, { client: client_options }, contest_options_source
      expect(jobs_with_handler_like('client_registered').count).to eq 1
      expect(jobs_with_handler_like('user_registration_info').count).to eq 1
    end

    it 'applies promocode' do
      post :create, { client: client_options }, contest_options_source
      client = Client.last
      expect(client.promocodes).to be_exists
    end

    it 'schedules checking of billing info' do
      post :create, { client: client_options }, contest_options_source
      expect(jobs_with_handler_like('StripeCustomerRegistration').count).to eq 1
    end

    context 'when not unique email' do
      let(:initial_client_count) { 1 }

      before do
        Fabricate(:client, email: client_options[:email])
      end

      it 'does not create client' do
        post :create, { client: client_options }, contest_options_source
        expect(Client.count).to eq initial_client_count
      end
    end
  end

  describe 'PATCH update' do
    let(:new_client_attributes) do
      { first_name: 'new first name',
        last_name: 'new last name',
        address: 'new address',
        city: 'new city',
        state: 'new state',
        zip: '123456',
        card_number: test_card_number,
        card_type: 'new type',
        card_ex_month: '12',
        card_ex_year: Time.current.year + 5,
        card_cvc: '444'
      }
    end

    describe 'client attributes updating' do
      before do
        sign_in(client)
        patch :update, client: new_client_attributes, id: client.id
        client.reload
      end

      it 'updates client string attributes' do
        new_client_attributes.except(*integer_attributes).each do |attribute, value|
          expect(client[attribute]).to eq value
        end
      end

      it 'updates client integer attributes' do
        integer_attributes.each do |attribute|
          expect(client[attribute]).to eq new_client_attributes[attribute].to_i
        end
      end
    end

    describe 'client password updating' do
      let(:new_password) { 'new password' }

      context 'correct params' do
        before do
          sign_in(client)
          patch :update, password: { old_password: default_password,
                                     new_password: new_password,
                                     confirm_password: new_password }, id: client.id
          client.reload
        end

        it 'updates password' do
          expect(client.valid_password?(default_password)).to be_falsey
          expect(client.valid_password?(new_password)).to be_truthy
        end
      end

      context 'wrong confirmation password' do
        before do
          sign_in(client)
          patch :update, password: { old_password: default_password,
                                     new_password: new_password,
                                     confirm_password: 'wrong' }, id: client.id
          client.reload
        end

        it 'does not change password' do
          expect(client.valid_password?(default_password)).to be_truthy
        end
      end

      context 'wrong old password' do
        before do
          sign_in(client)
          patch :update, password: { old_password: 'wrong',
                                     new_password: new_password,
                                     confirm_password: new_password }, id: client.id
          client.reload
        end

        it 'does not change password' do
          expect(client.valid_password?(default_password)).to be_truthy
        end
      end
    end
  end

  describe 'GET client_center' do
    before do
      sign_in(client)
    end

    it 'redirects to Entries page if responses present' do
      client_contest =  Fabricate(:contest, client: client, status: 'submission')
      Fabricate(:contest_request, contest: client_contest)
      get :client_center
      expect(response).to redirect_to entries_client_center_index_path
    end

    it 'redirects to Entries page if no responses present' do
      get :client_center
      expect(response).to redirect_to entries_client_center_index_path
    end
  end

  describe 'GET entries' do
    before do
      sign_in(client)
      Fabricate(:portfolio)
      allow_any_instance_of(Image).to receive(:url_for_downloading) { '' }
    end

    context 'designers present' do
      let!(:designers) { Fabricate.times(4, :portfolio).map(&:designer) }

      it 'returns page' do
        Fabricate(:contest, client: client, status: 'submission')
        get :entries
        expect(response).to render_template(:entries_invitations)
      end

      context 'responses present' do
        let(:contest) { Fabricate(:contest, client: client, status: 'submission') }
        let!(:submitted) { Fabricate(:contest_request,
                                     designer: designers[0],
                                     contest: contest,
                                     status: 'submitted',
                                     lookbook: Fabricate(:lookbook)) }
        let!(:draft) { Fabricate(:contest_request,
                                 designer: designers[1],
                                 contest: contest,
                                 status: 'draft',
                                 lookbook: Fabricate(:lookbook)) }
        let!(:fulfillment) { Fabricate(:contest_request,
                                       designer: designers[2],
                                       contest: contest,
                                       status: 'fulfillment_ready',
                                       lookbook: Fabricate(:lookbook)) }

        def create_contest_request(cont)
          Fabricate(:contest_request,
                    designer: designers[3],
                    contest: cont,
                    status: 'submitted',
                    answer: 'winner',
                    lookbook: Fabricate(:lookbook))
        end

        def create_contest
          Fabricate(:contest, client: client, status: 'submission')
        end

        it 'views only submitted and fulfillment requests' do
          get :entries
          expect(assigns(:entries_page).contest_requests).to match_array([submitted, fulfillment])
        end

        it 'filters responses by answer' do
          contest.start_winner_selection!
          draft.update_attributes!(answer: 'no')
          fulfillment.update_attributes!(answer: 'favorite')
          submitted.update_attributes!(answer: 'winner')
          get :entries, answer: 'winner'
          expect(assigns(:entries_page).contest_requests).to match_array([submitted])
        end

        it 'returns winner contest request' do
          contest.start_winner_selection!
          submitted.update_attributes!(answer: 'winner')
          get :entries, answer: 'winner'
          expect(assigns(:entries_page).won_contest_request).to eq(submitted)
        end

        context 'contest in fulfillment state' do
          before do
            contest.update_attributes!(status: 'fulfillment')
          end

          it 'returns page' do
            ContestRequest::FULFILLMENT_STATUSES.each do |status|
              cont = create_contest
              contest_request = create_contest_request(cont)
              contest_request.update_attributes!(status: status)
              cont.update_attributes!(status: 'fulfillment')
              PhasesStripe::PHASES.each_index do |index|
                get :entries, view: index
                expect(response).to render_template(:entries)
              end
              contest_request.destroy
            end
          end
        end

        context 'contest finished' do
          it 'returns page' do
            contest_request = Fabricate(:contest_request,
                                        designer: designers[3],
                                        contest: contest,
                                        status: 'finished',
                                        answer: 'winner',
                                        lookbook: Fabricate(:lookbook))
            contest.update_attributes!(status: 'finished')
            PhasesStripe::PHASES.each_index do |index|
              get :entries, view: index
              expect(response).to render_template(:entries)
            end
          end
        end
      end
    end

    it 'returns page' do
      Fabricate(:contest, client: client, status: 'submission')
      contest = client.last_contest
      client.update_attributes!(status: 'finished')
      fulfillment = Fabricate(:contest_request,
                              designer: Fabricate(:designer),
                              contest: contest,
                              status: 'finished',
                              answer: 'winner',
                              lookbook: Fabricate(:lookbook))
      fulfillment.image_items.create!(kind: 'product_items', phase: 'collaboration', status: 'temporary')
      fulfillment.image_items.create!(kind: 'product_items', phase: 'final_design', status: 'published')
      fulfillment.image_items.create!(kind: 'product_items', phase: 'collaboration', status: 'temporary')
      fulfillment.image_items.create!(kind: 'product_items', phase: 'final_design', status: 'published')
      get :entries
      expect(response).to render_template(:entries)
      ContestPhases::INDICES_TO_PHASES.keys.each do |phase_index|
        get :entries, view: phase_index
        expect(response).to render_template(:entries)
      end
    end

    context 'client has no contest' do
      before do
        client.contests.destroy_all
      end

      it 'redirects to contest creation' do
        get :entries
        expect(response).to redirect_to(design_brief_contests_path)
      end
    end
  end

  describe 'GET pictures_dimension' do
    before do
      sign_in(client)
      Fabricate(:contest, client: client)
    end

    it 'returns page' do
      get :pictures_dimension
      expect(response).to render_template(:pictures_dimension)
    end
  end

  describe 'GET concept_boards_page' do
    before do
      sign_in(client)
      Fabricate(:contest, client: client)
    end

    it 'returns json' do
      get :concept_boards_page
      json = JSON.parse(response.body)
      expect(json).to include('new_items_html', 'show_mobile_pagination', 'next_page')
    end
  end
end
