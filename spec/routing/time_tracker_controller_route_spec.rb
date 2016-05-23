require 'rails_helper'

RSpec.describe TimeTrackerController do
  describe 'GET /time_tracker' do
    it 'routes to designer center time tracker ' do
      expect(get: '/contests/0/time_tracker').to route_to('time_tracker#designer_view', contest_id: '0')
    end

    it 'routes to client center time tracker ' do
      expect(get: '/client_center/entries/0/time_tracker').to route_to('time_tracker#client_view', id: '0')
    end
  end

  describe 'GET /time_tracker/confirm_purchase' do
    it 'routes to client center purchase initialization page' do
      expect(post: '/client_center/entries/0/time_tracker/initialize_purchase').to route_to('time_tracker#initialize_purchase', id: '0')
    end
  end

  describe 'POST contests/0/time_tracker/attachments' do
    it 'routes creating time tracker attachment' do
      expect(post: 'contests/0/time_tracker/attachments').to route_to('time_tracker_attachments#create', contest_id: '0')
    end
  end
end
