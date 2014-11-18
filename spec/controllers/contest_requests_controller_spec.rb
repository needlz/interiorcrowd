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
    it "should return 'saved':'true' if answer is set to 'winner'" do
      post :answer, id: request.id, answer: 'winner'
      expect(JSON.parse(response.body)['saved']).to eq true
    end

    it "should return 'saved':'true' if answer is set to 'no'" do
      post :answer, id: request.id, answer: 'no'
      expect(JSON.parse(response.body)['saved']).to eq true
    end

    it "should return 'saved':'true' if answer is set to 'favorite'" do
      post :answer, id: request.id, answer: 'favorite'
      expect(JSON.parse(response.body)['saved']).to eq true
    end

    it "should return 'saved':'true' if answer is set to 'maybe'" do
      post :answer, id: request.id, answer: 'maybe'
      expect(JSON.parse(response.body)['saved']).to eq true
    end

    it "should return 'saved':'false' if answer is set to unknown value" do
      post :answer, id: request.id, answer: 'what?'
      expect(JSON.parse(response.body)['saved']).to eq false
    end

    it "should return 'saved':'false' if request id is wrong" do
      post :answer, id: 0, answer: 'no'
      expect(JSON.parse(response.body)['saved']).to eq false
    end

    it "should return 'saved':'false' if user is not logged as contest creator" do
      session[:client_id] = 0
      post :answer, id: 0, answer: 'no'
      expect(JSON.parse(response.body)['saved']).to eq false
    end
  end
end