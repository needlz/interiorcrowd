require 'rails_helper'
require 'spec_helper'

RSpec.describe ClientsController do
  include ClientsHelper

  before do
    allow_any_instance_of(Mailer).to receive(:user_registration).and_return(Hashie::Mash.new({ deliver: '' }))
  end

  let(:client) { Fabricate(:client) }
  let(:appeals) { (0..2).map { |index| Appeal.create!(first_name: "first_name#{ index }", second_name: "second_name#{ index }") } }
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

  describe 'GET edit_attribute' do
    it 'returns attribute form for profile of current client' do
      session[:client_id] = client.id
      profile_rows.each do |profile_row|
        attribute = profile_row[:attribute]
        get :edit_attribute, attribute: attribute
        expect(response).to be_ok
        expect(response).to render_template(partial: "clients/client_center/profile/forms/_#{ attribute }")
      end
    end

    it 'fails if client is not logged in' do
      expect { get :edit_attribute, atribute: helper.profile_rows[0][:attribute] }.to raise_error
    end
  end
end
