require "rails_helper"

RSpec.describe RoomDesignsController do
  describe 'POST /room_designs' do
    it 'routes to room creating for corresponding contest request' do
      expect(post: '/contest_requests/0/room_designs').to route_to('room_designs#create', contest_request_id: '0')
    end
  end
end