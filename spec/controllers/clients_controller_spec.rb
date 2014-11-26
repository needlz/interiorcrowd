require 'rails_helper'
require 'spec_helper'

RSpec.describe ClientsController do
  before do
    allow_any_instance_of(Mailer).to receive(:user_registration).and_return(Hashie::Mash.new({ deliver: '' }))
  end

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
end
