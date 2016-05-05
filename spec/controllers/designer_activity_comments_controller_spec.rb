require 'rails_helper'

RSpec.describe DesignerActivityCommentsController, type: :controller do

  let(:contest) { Fabricate(:contest) }
  let(:time_tracker) { Fabricate(:time_tracker, contest: contest) }
  let(:client) { Fabricate(:client) }
  let(:activity) { Fabricate(:designer_activity, time_tracker: time_tracker) }
  let(:comment_text) { 'text' }

  describe 'POST #create' do
    before do
      sign_in(client)
    end

    it 'creates comments' do
      expect {
        post(:create,
             contest_id: contest.id,
             designer_activity_id: activity.id,
             designer_activity_comment: { text: comment_text }) }.
        to(change{ activity.comments.count }.from(0).to(1))
      comment = activity.comments.first
      expect(comment.author).to eq client
      expect(comment.text).to eq comment_text
    end
  end

end
