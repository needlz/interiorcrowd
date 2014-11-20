require 'rails_helper'
require 'spec_helper'

RSpec.describe ContestsController do
  let(:client) { Client.create!(email: 'client@example.com', first_name: 'First', last_name: 'Last', password: '123456') }
  let(:contest) { Contest.create!(client: client) }

  before do
    session[:client_id] = client.id
  end

  describe 'GET option' do
    it 'returns OK status if space_pictures was passed' do
      get :option, id: contest.id, option: 'space_pictures'
      expect(response).to be_ok
    end

    it 'throws exception if unknown option was passed' do
      expect { get :option, id: contest.id, option: '' }.to raise_error
    end
  end
end
