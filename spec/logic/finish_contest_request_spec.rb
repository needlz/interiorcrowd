require 'rails_helper'

RSpec.describe FinishContestRequest do

  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:completed_contest, client: client, status: 'final_fulfillment') }
  let(:designer) { Fabricate(:designer) }
  let(:contest_request) { Fabricate(:contest_request,
                                    contest: contest,
                                    designer: designer,
                                    status: 'fulfillment_approved') }

  it 'notifies client' do
    finish_contest_request = FinishContestRequest.new(contest_request)
    finish_contest_request.perform
    expect(jobs_with_handler_like('designer_submitted_final_design').count).to eq 1
  end

  it 'finishes contest request' do
    finish_contest_request = FinishContestRequest.new(contest_request)
    finish_contest_request.perform
    expect(contest_request.status).to eq('finished')
  end

  it 'finishes contest' do
    finish_contest_request = FinishContestRequest.new(contest_request)
    finish_contest_request.perform
    expect(contest.status).to eq('finished')
  end

  it 'sets finishing date' do
    finish_contest_request = FinishContestRequest.new(contest_request)
    finish_contest_request.perform
    expect(contest.finished_at).to be_within(5.seconds).of(Time.current)
  end

  it 'breaks the transaction when contest has wrong status' do
    contest.update_attributes(status: 'winner_selection')
    expect do
      finish_contest_request = FinishContestRequest.new(contest_request)
      finish_contest_request.perform
    end.to raise_error(StateMachine::InvalidTransition)
  end

end
