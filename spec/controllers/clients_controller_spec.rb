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
  let(:client_options){
    { password: 'password',
      password_confirmation: 'password',
      first_name: 'firstname',
      last_name: 'lastname',
      email: 'email@example.com',
      address: 'address',
      name_on_card: 'name_on_card',
      card_type: 'Visa',
      city: 'City',
      state: 'state',
      card_ex_month: '12',
      card_ex_year: '2000',
      card_cvc: '123',
      zip: '81100'
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
      client_options.except(:password, :password_confirmation, *integer_attributes).each do |attribute, value|
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
      expect(Delayed::Job.where('handler LIKE ?', "%client_registered%").count).to eq 1
      expect(Delayed::Job.where('handler LIKE ?', "%user_registration_info%").count).to eq 1
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
        card_number: '4242',
        card_type: 'new type',
        card_ex_month: '12',
        card_ex_year: '2002',
        card_cvc: '444'
      }
    end

    describe 'updates' do
      before do
        sign_in(client)
        patch :update, client: new_client_attributes, id: client.id
        client.reload
      end

      it 'client string attributes' do
        new_client_attributes.except(*integer_attributes).each do |attribute, value|
          expect(client[attribute]).to eq value
        end
      end

      it 'client integer attributes' do
        integer_attributes.each do |attribute|
          expect(client[attribute]).to eq new_client_attributes[attribute].to_i
        end
      end
    end
  end

  describe 'GET client_center' do
    before do
      sign_in(client)
    end

    it 'redirects to Entries page if responses present' do
      client_contest =  Fabricate(:contest, client: client)
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
      Fabricate(:contest, client: client)
      Fabricate(:portfolio)
    end

    context 'designers present' do
      let!(:designers) { Fabricate.times(4, :portfolio).map(&:designer) }

      it 'returns page' do
        get :entries
        expect(response).to render_template(:entries)
      end

      context 'responses present' do
        let(:contest) { Fabricate(:contest, client: client) }
        let!(:submitted) { Fabricate(:contest_request, designer: designers[0], contest: contest, status: 'submitted') }
        let!(:draft) { Fabricate(:contest_request, designer: designers[1], contest: contest, status: 'draft') }
        let!(:fulfillment) { Fabricate(:contest_request, designer: designers[2], contest: contest, status: 'fulfillment') }

        it 'views only submitted and fulfillment requests' do
          get :entries
          expect(assigns(:contest_requests)).to match_array([submitted, fulfillment])
        end

        it 'filters responses by answer' do
          contest.start_winner_selection!
          draft.update_attributes!(answer: 'no')
          fulfillment.update_attributes!(answer: 'favorite')
          submitted.update_attributes!(answer: 'winner')
          get :entries, answer: 'winner'
          expect(assigns(:contest_requests)).to match_array([submitted])
        end

        it 'returns winner contest request' do
          contest.start_winner_selection!
          submitted.update_attributes!(answer: 'winner')
          get :entries, answer: 'winner'
          expect(assigns(:won_contest_request)).to eq(submitted)
        end

        context 'has finished concept board' do
          before do
            Fabricate(:contest_request, designer: designers[3], contest: contest, status: 'finished', answer: 'winner')
          end

          it 'returns page' do
            get :entries
            expect(response).to render_template(:entries)
          end
        end
      end
    end

    it 'returns page' do
      contest = client.last_contest
      client.update_attributes!(status: 'finished')
      fulfillment = Fabricate(:contest_request, designer: Fabricate(:designer), contest: contest, status: 'finished', answer: 'winner')
      fulfillment.image_items.create!(kind: 'product_items', final: true)
      get :entries
      expect(response).to render_template(:entries)
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
end
