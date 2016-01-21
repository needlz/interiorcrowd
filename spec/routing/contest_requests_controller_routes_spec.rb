require "rails_helper"

RSpec.describe ContestRequestsController do
  describe 'POST /add_comment' do
    it 'routes to comment adding for corresponding contest request' do
      expect(post: '/contest_requests/0/comments').to route_to('concept_board_comments#create', contest_request_id: '0')
    end
  end

  describe 'POST /:id/add_comment' do
    it 'routes to comment adding for new contest request' do
      expect(post: 'designer_center/contests/0/comments').to route_to('concept_board_comments#create', designer_center_contest_id: '0')
    end
  end
end
