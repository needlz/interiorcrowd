require 'rails_helper'

RSpec.describe RoomDesignsController do

  describe 'POST create' do
    let(:room_creation_params) do
      {
          contest_request_id: 2,
          room: { room: 'kitchen' }
      }
    end

    it 'creates new room to specific contest request' do
      expect(RoomDesign.count).to eq 0
      post :create, room_creation_params
      expect(RoomDesign.count).to eq 1
    end
  end
end