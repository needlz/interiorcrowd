require 'rails_helper'
require 'spec_helper'

RSpec.describe TimeTrackerAttachmentsController do
  render_views

  let(:contest) { Fabricate(:contest_in_submission) }
  let(:designer) { Fabricate(:designer) }
  let(:contest_request) { Fabricate(:contest_request, contest: contest, designer: designer, answer: 'winner') }
  let(:time_tracker) { Fabricate(:time_tracker, contest: contest) }
  let(:attachment) { Fabricate(:image, uploader_role: designer.role, uploader_id: designer.id) }

  describe 'CREATE attachment' do
    before do
      sign_in(designer)
    end

    it 'associates attachment with a time tracker' do
      contest_request
      time_tracker
      post :create, contest_id: contest.id, id: attachment.id, format: :json
      expect(JSON.parse(response.body)['created']). to eq attachment.id
      expect(time_tracker.attachments.reload.to_a).to match_array [attachment]
    end
  end
  
end
