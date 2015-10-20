require 'rails_helper'

RSpec.describe ContestRequestSubmission do

  let(:designer) { Fabricate(:designer) }
  let(:contest) { Fabricate(:contest, status: 'submission') }
  let(:contest_request) { Fabricate(:contest_request, designer: designer, contest: contest, status: 'draft') }

  it 'submits the contest request' do
    expect(contest_request.status).to eq('draft')
    ContestRequestSubmission.new(contest_request).perform
    expect(contest_request.reload.status).to eq('submitted')
  end

  it 'sets the submission date' do
    ContestRequestSubmission.new(contest_request).perform
    expect(contest_request.reload.submitted_at).to be_within(5.seconds).of(Time.current)
  end

  it 'creates notification about board submission' do
    expect do
      ContestRequestSubmission.new(contest_request).perform
    end.to change{BoardSubmittedDesignerNotification.count}.by(1)
  end

  it 'sends email about board submission' do
    ContestRequestSubmission.new(contest_request).perform
    expect(jobs_with_handler_like('concept_board_received').count).to eq 1
  end

  it 'interrupt the transaction when contest request has incorrect status' do
    contest_request.update_attributes(status: 'submitted')
    expect do
      ContestRequestSubmission.new(contest_request).perform
    end.to raise_error(StateMachine::InvalidTransition), change{BoardSubmittedDesignerNotification.count}.by(0)
    expect(contest_request.reload.submitted_at).to be_nil
    expect(jobs_with_handler_like('concept_board_received').count).to eq 0
  end
end
