require "rails_helper"

RSpec.describe ContestRequestsController do
  describe 'POST /add_comment' do
    it 'routes to comment adding for corresponding contest request' do
      expect(post: '/contest_requests/0/add_comment').to route_to('contest_requests#add_comment', id: '0')
    end
  end

  describe 'POST /:id/add_comment' do
    it 'routes to comment adding for new contest request' do
      expect(post: '/contest_requests/add_comment').to route_to('contest_requests#add_comment')
    end
  end
end
