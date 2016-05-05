require 'rails_helper'

RSpec.describe DesignerActivitiesController, type: :controller do

  let(:contest) { Fabricate(:contest) }
  let!(:time_tracker) { Fabricate(:time_tracker, contest: contest) }
  let(:client) { Fabricate(:client) }
  let(:designer) { Fabricate(:designer) }

  describe 'POST #create' do
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

  describe 'PATCH #read' do
    let(:activity) { Fabricate(:designer_activity, time_tracker: time_tracker) }
    let!(:foreign_comment) { Fabricate(:designer_activity_comment, designer_activity: activity, author: designer) }
    let!(:my_comment) { Fabricate(:designer_activity_comment, designer_activity: activity, author: client) }

    before do
      sign_in(client)
    end

    it 'updates read attribute' do
      patch(:read,
            contest_id: contest.id,
            id: activity.id)
      expect(foreign_comment.reload.read).to be_truthy
      expect(my_comment.reload.read).to be_falsey
    end
  end

end
