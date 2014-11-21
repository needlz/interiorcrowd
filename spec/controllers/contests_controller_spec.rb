require 'rails_helper'
require 'spec_helper'

RSpec.describe ContestsController do
  let(:client) { Client.create!(email: 'client@example.com', first_name: 'First', last_name: 'Last', password: '123456') }
  let(:contest) { Contest.create!(client: client) }

  before do
    session[:client_id] = client.id
  end

  describe 'GET option' do
    it 'returns html of options' do
      ContestView::OPTIONS_PARTIALS.each do |option|
        get :option, id: contest.id, option: option
        expect(response).to be_ok
        expect(response).to render_template(partial: "contests/options/_#{ option }_options")
      end
    end

    it 'throws exception if unknown option was passed' do
      expect { get :option, id: contest.id, option: '' }.to raise_error
    end
  end
end
