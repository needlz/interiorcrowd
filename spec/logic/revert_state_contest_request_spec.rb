require 'rails_helper'

RSpec.describe RevertState::ContestRequest do

  let(:client) { Fabricate(:client) }
  let(:another_client) { Fabricate(:client) }
  let(:designer) { Fabricate(:designer) }
  let(:revertor) { RevertState::ContestRequest.new(contest_request) }

  context 'when contest request won' do
    let(:contest) { Fabricate(:completed_contest, client: client, status: 'fulfillment') }
    let(:another_contest) { Fabricate(:completed_contest, client: another_client, status: 'fulfillment') }
    let(:contest_request) do
      r = Fabricate(:contest_request, designer: designer, contest: contest, status: 'fulfillment_ready')
      r.update_column(:answer, 'winner')
      r
    end
    let!(:notification) { Fabricate(:designer_winner_notification,
                                    user_id: designer.id,
                                    contest_request_id: contest_request.id) }
    let!(:another_notification) { Fabricate(:designer_winner_notification, user_id: 1, contest_request_id: 1) }
    let!(:loser_notification) { Fabricate(:designer_loser_info_notification, user_id: 1, contest_id: contest.id) }
    let!(:another_loser_notification) { Fabricate(:designer_loser_info_notification,
                                                  user_id: 1,
                                                  contest_id: another_contest.id) }

    context 'when reverting to submitted' do
      it 'removes notification about submission' do
        revertor.to_submitted
        expect(DesignerWinnerNotification.exists?(notification.id)).to be_falsey
        expect(DesignerWinnerNotification.exists?(another_notification.id)).to be_truthy
      end

      it 'removes notifications about loosing a contest' do
        revertor.to_submitted
        expect(DesignerLoserInfoNotification.exists?(loser_notification.id)).to be_falsey
        expect(DesignerLoserInfoNotification.exists?(another_loser_notification.id)).to be_truthy
      end
    end

  end

end
