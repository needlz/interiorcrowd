require 'rails_helper'

RSpec.describe DesignerActivitiesController, type: :controller do

  describe "POST #create" do
    let!(:contest) { Fabricate(:contest) }
    let!(:time_tracker) { Fabricate(:time_tracker, contest: contest) }
    let(:client) { Fabricate(:client) }

    before do
      sign_in(client)
    end

    it "returns http success" do
      post :create, contest_id: contest.id, designer_activity: { comments: {} }
      expect(response).to have_http_status(:success)
    end
  end

end
