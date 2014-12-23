require 'rails_helper'
require 'spec_helper'

RSpec.describe ClientsController do
  render_views

  include ClientsHelper

  before do
    allow_any_instance_of(Mailer).to receive(:user_registration).and_return(Hashie::Mash.new({ deliver: '' }))
  end

  let(:client) { Fabricate(:client) }
  let(:appeals) do
    (0..2).map do |index|
      Appeal.create!(first_name: "first_name#{ index }", second_name: "second_name#{ index }")
    end
  end
  let(:client_options){
    { password: 'password',
      password_confirmation: 'password',
      designer_level_id: 2,
      first_name: 'firstname',
      last_name: 'lastname',
      email: 'email@example.com',
      address: 'address',
      name_on_card: 'name_on_card',
      state: 'state',
      zip: '81100'
    }
  }

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
      post :create, { client: client_options }, contest_options_source.except(:design_brief)
      expect(Contest.count).to eq 0
      expect(Client.count).to eq 1
    end
  end

  describe 'PATCH update' do
    let(:new_client_attributes) do
      { first_name: 'new first name',
        last_name: 'new last name',
        address: 'new address',
        state: 'new state',
        zip: '123456',
        card_number: '4242',
        card_ex_month: '12',
        card_ex_year: '2002',
        card_cvc: '444'
      }
    end
    let(:integer_attributes) { [:zip, :card_ex_month, :card_ex_year, :card_cvc] }

    describe 'updates' do
      before do
        sign_in(client)
        patch :update, client: new_client_attributes, id: client.id
        client.reload
        expect(response).to redirect_to(profile_client_center_index_path)
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

    it 'redirects to Brief page if no responses present' do
      get :client_center
      expect(response).to redirect_to brief_client_center_index_path
    end
  end

  describe 'GET entries' do
    before do
      sign_in(client)
      Fabricate(:contest, client: client)
    end

    it 'returns page' do
      get :entries
      expect(response).to render_template(:entries)
    end
  end
end
