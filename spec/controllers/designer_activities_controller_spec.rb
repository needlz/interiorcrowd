require 'rails_helper'

RSpec.describe DesignerActivitiesController, type: :controller do

  describe 'POST #create' do
    let!(:contest) { Fabricate(:contest) }
    let!(:time_tracker) { Fabricate(:time_tracker, contest: contest) }
    let(:client) { Fabricate(:client) }

    before do
      sign_in(client)
    end

    it 'returns http success' do
      expect { post(:create, contest_id: contest.id, designer_activity: { start_date: '5/3/2016',
                                                                          due_date: '12/3/2016',
                                                                          hours: 2 }) }.to(
        change{ time_tracker.designer_activities.count }.from(0).to(1)
      )
      expect(response).to have_http_status(:success)
    end

    context 'when the text of a comment passed' do
      let(:comment_text) { 'text' }

      it 'creates comment' do
        post :create, contest_id: contest.id, designer_activity: { start_date: '5/3/2016',
                                                                   due_date: '12/3/2016',
                                                                   hours: 2,
                                                                   comments: { text: comment_text } }
        expect(time_tracker.designer_activities.first.comments.first.text).to eq comment_text
      end
    end

    context 'when the text of a comment not passed' do
      it 'does not create comment' do
        post :create, contest_id: contest.id, designer_activity: { start_date: '5/3/2016',
                                                                   due_date: '12/3/2016',
                                                                   hours: 2 }
        expect(time_tracker.designer_activities.first.comments).to be_empty
      end
    end
  end

end
