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
      city: 'City',
      state: 'state',
      zip: '81100',
      promocode: promocode.promocode
    }
  }
  let(:integer_attributes) { [:zip] }

  describe 'POST create' do
    context 'when all required options are set' do
      it 'creates contest and client' do
        expect(Contest.count).to eq 0
        expect(Client.count).to eq 0
        post :create, { client: client_options }, contest_options_source
        expect(Contest.count).to eq 1
        expect(Client.count).to eq 1
      end

      it 'redirects to entries page' do
        post :create, { client: client_options }, contest_options_source
        expect(response).to redirect_to(payment_details_contests_path(id: Contest.last.id))
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
      end

      it 'applies promocode' do
        post :create, { client: client_options }, contest_options_source
        contest = Contest.last
        expect(contest.promocodes).to be_exists
      end

      it 'doesn\'t apply the same promocode again' do
        post :create, { client: client_options }, contest_options_source

        contest = Contest.last
        expect{ contest.promocodes << promocode }.to raise_exception(ActiveRecord::RecordInvalid)
      end

      it 'does not send email with explanations how to finish intake form' do
        post :create, { client: client_options }, contest_options_source
        expect(jobs_with_handler_like('account_creation').count).to eq 0
      end

      context 'when automatic payment enabled' do
        before do
          allow(Settings).to receive(:automatic_checkout_enabled) { true }
        end

        context 'when brief completed' do
          let(:params) { contest_options_source }

          it 'creates contest in brief_pending status' do
            post :create, { client: client_options }, params
            contest = Contest.last
            expect(contest).to be_brief_pending
          end
        end

        context 'when brief not completed' do
          let(:params) { contest_options_source.deep_merge(design_space: { document_id: nil }) }

          it 'creates contest in brief_pending status' do
            post :create, { client: client_options }, params
            contest = Contest.last
            expect(contest).to be_brief_pending
          end
        end
      end

      context 'when automatic payment disabled' do
        before do
          allow(Settings).to receive(:automatic_checkout_enabled) { false }
        end

        context 'when brief completed' do
          let(:params) { contest_options_source }

          it 'creates contest in brief_pending status' do
            post :create, { client: client_options }, params
            contest = Contest.last
            expect(contest).to be_brief_pending
          end
        end

        context 'when brief not completed' do
          let(:params) { contest_options_source.deep_merge(design_space: { document_id: nil }) }

          it 'creates contest in brief_pending status' do
            post :create, { client: client_options }, params
            contest = Contest.last
            expect(contest).to be_brief_pending
          end
        end
      end
    end

    context 'when some of required options are not set' do
      it 'does not create contest if some of required options were not set' do
        expect(Contest.count).to eq 0
        expect(Client.count).to eq 0
        expect { post :create, { client: client_options }, contest_options_source.except(:design_brief) }.to raise_error(ArgumentError)
        expect(Contest.count).to eq 0
        expect(Client.count).to eq 1
      end
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

  describe 'POST sign_up_with_email' do

    context 'when valid email and password' do
      let(:email) { 'email@example.com' }

      before do
        post :sign_up_with_email, client: { email: email, password: 'pw', password_confirmation: 'pw' }
      end

      it 'creates client and incomplete contest' do
        client = Client.first
        expect(client.email).to eq email
        expect(client.contests.first).to be_incomplete
      end

      it 'sends only an email with explanations how to finish intake form' do
        expect(jobs_with_handler_like('account_creation').count).to eq 1
        expect(jobs_with_handler_like('client_registered').count).to eq 0
      end

      it 'redirects to incomplete step of contest' do
        client = Client.first
        expect(response).to redirect_to ContestCreationWizard.incomplete_step_path(client.reload.contests.first)
      end
    end
  end

  describe 'POST sign_up_with_facebook' do
    context 'when valid access_token passed' do
      let(:first_name) { 'first name' }
      let(:last_name) { 'last name' }
      let(:email) { 'email@example.com' }
      let(:id) { '1' }

      before do
        allow_any_instance_of(Koala::Facebook::API).to receive(:api) do |action, params_hash|
          { 'id' => id,
            'name' => 'name',
            'email' => email,
            'first_name' => first_name,
            'last_name' => last_name }
        end

        post :sign_up_with_facebook, token: 'oauth_token'
      end

      it 'creates client and incomplete contest' do
        client = Client.first
        expect(client.email).to eq email
        expect(client.first_name).to eq first_name
        expect(client.last_name).to eq last_name
        expect(client.contests.first).to be_incomplete
      end

      it 'redirects to incomplete step of contest' do
        client = Client.first
        expect(response).to redirect_to ContestCreationWizard.incomplete_step_path(client.reload.contests.first)
      end

      it 'sends only an email with explanations how to finish intake form to client' do
        expect(jobs_with_handler_like('account_creation').count).to eq 1
        expect(jobs_with_handler_like('client_registered').count).to eq 0
      end
    end

    context 'when invalid access_token passed' do
      it 'does not create client' do
        allow_any_instance_of(Koala::Facebook::API).to receive(:api) do |action, params_hash|
          {
              'error' => {
                  'message' => 'Invalid OAuth access token.',
                  'type' => 'OAuthException',
                  'code' => 190
              }
          }
        end

        post :sign_up_with_facebook
        expect(Client.count).to eq 0
        expect(Contest.count).to eq 0
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
        zip: '123456'
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
      expect(response).to redirect_to client_center_entries_path
    end

    it 'redirects to Entries page if no responses present' do
      get :client_center
      expect(response).to redirect_to client_center_entries_path
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

  describe 'GET unsubscribe' do
    context 'valid url' do
      let(:valid_signature) { client.access_token }

      it 'unsubscribes a client' do
        get :unsubscribe, signature: valid_signature
        expect(response).to have_http_status(:ok)
        expect(response.body).to eq 'You have been unsubscribed'
        expect(client.reload.email_opt_in).to be_falsey
      end
    end

    context 'invalid url' do
      let(:invalid_signature) { 'invalid_signature' }

      it 'returns 404' do
        get :unsubscribe, signature: invalid_signature
        expect(response).to have_http_status(:not_found)
        expect(client.email_opt_in).to be_truthy
      end
    end
  end

  describe 'GET brief' do
    before do
      sign_in(client)
    end

    context 'when contest is unknown' do
      it 'returns 404' do
        get :brief, id: 0
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when contest is complete' do
      let(:contest) { Fabricate(:contest, client: client, status: Contest::COMPLETED_NON_FINISHED_STATUSES[0]) }

      it 'returns brief page' do
        dont_raise_i18n_exceptions do
          get :brief, id: contest.id
          expect(response).to render_template(:brief)
        end
      end
    end

    context 'when contest is incomplete' do
      let(:contest) { Fabricate(:contest, client: client, status: Contest::INCOMPLETE_STATUSES[0]) }

      it 'returns brief page' do
        get :brief, id: contest.id
        expect(response).to redirect_to ContestCreationWizard.incomplete_step_path(contest)
      end
    end
  end

end
