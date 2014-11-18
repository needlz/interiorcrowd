require 'rails_helper'
require 'spec_helper'

RSpec.describe ContestRequestsController do
  let(:client) { Client.create!(email: 'client@example.com', first_name: 'First', last_name: 'Last', password: '123456') }
  let(:contest) { Contest.create!(client: client) }
  let(:request) { ContestRequest.create!(contest: contest) }

  before do
    session[:client_id] = client.id
  end

  describe "POST answer" do
    let(:answered) { JSON.parse(response.body)['answered'] }

    it 'saves if answer is winner' do
      post :answer, id: request.id, answer: 'winner'
      expect(answered).to eq true
    end

    it 'saves if answer is no' do
      post :answer, id: request.id, answer: 'no'
      response.body
      expect(answered).to eq true
    end

    it 'saves if answer is favorite' do
      post :answer, id: request.id, answer: 'favorite'
      expect(answered).to eq true
    end

    it 'saves if answer is maybe' do
      post :answer, id: request.id, answer: 'maybe'
      expect(answered).to eq true
    end

    it 'does not save if answer is unknown' do
      post :answer, id: request.id, answer: 'what?'
      expect(answered).to eq false
    end

    it 'does not save if request id is wrong' do
      expect { post :answer, id: 0, answer: 'no' }.to raise_exception
    end

    it 'does not save if user is not logged as contest creator' do
      session[:client_id] = 0
      post :answer, id: request.id, answer: 'no'
      expect(answered).to be_falsy
    end
  end
end
