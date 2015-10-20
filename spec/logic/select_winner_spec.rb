require 'rails_helper'

RSpec.describe SelectWinner do

  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:contest, client: client, status: 'submission') }
  let(:contest_request) { Fabricate(:contest_request, contest: contest) }

  it 'notifies client' do
    select_winner = SelectWinner.new(contest_request)
    select_winner.perform
    expect(jobs_with_handler_like('client_has_picked_a_winner').count).to eq 1
  end

  it 'updates date of winning' do
    select_winner = SelectWinner.new(contest_request)
    select_winner.perform
    expect(contest_request.reload.won_at).to be_within(5.seconds).of(Time.current)
  end

  it 'changes contest status' do
    select_winner = SelectWinner.new(contest_request)
    select_winner.perform
    expect(contest.status).to eq('fulfillment')
  end

  it 'creates designer winner notification' do
    expect do
      select_winner = SelectWinner.new(contest_request)
      select_winner.perform
    end.to change{ DesignerWinnerNotification.count }.by(1)
  end

  it 'rollbacks the transaction when error occurred during performing' do
    contest.update_attributes(status: 'closed')
    expect do
      select_winner = SelectWinner.new(contest_request)
      select_winner.perform
    end.to raise_error(ActiveRecord::RecordInvalid)
 end

end
