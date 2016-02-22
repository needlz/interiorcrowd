require 'rails_helper'

RSpec.describe SelectWinner do

  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:contest_in_submission, client: client) }
  let(:contest_request) { Fabricate(:contest_request, contest: contest) }

  it 'notifies client' do
    SelectWinner.perform(contest_request)
    expect(jobs_with_handler_like('client_has_picked_a_winner').count).to eq 1
  end

  it 'notifies designer' do
    SelectWinner.perform(contest_request)
    expect(jobs_with_handler_like('notify_designer_about_win').count).to eq 1
  end

  it 'notifies product owner' do
    SelectWinner.perform(contest_request)
    expect(jobs_with_handler_like('notify_product_owner_about_designer_win').count).to eq 1
  end

  it 'updates date of winning' do
    SelectWinner.perform(contest_request)
    expect(contest_request.reload.won_at).to be_within(5.seconds).of(Time.current)
  end

  it 'changes contest status' do
    SelectWinner.perform(contest_request)
    expect(contest.reload.status).to eq('fulfillment')
  end

  it 'creates designer winner notification' do
    expect do
      SelectWinner.perform(contest_request)
    end.to change{ DesignerWinnerNotification.count }.by(1)
  end

  it 'rollbacks the transaction when error occurred during performing' do
    contest.update_attributes(status: 'closed')
    expect do
      SelectWinner.perform(contest_request)
    end.to raise_error(ActiveRecord::RecordInvalid)
  end

  context 'on concurrent calls', concurrent: true do
    let(:contest_request) { Fabricate(:contest_request, contest: contest, lookbook: Fabricate(:lookbook)) }

    it 'creates only new lookbook item' do
      expect do
        select_winner = SelectWinner.new(contest_request)
        select_winner.concurrent_calls([:prepare_for_next_phase], :perform) do |processes|
          processes[0].run_until(:prepare_for_next_phase).wait
          processes[1].run_until(:prepare_for_next_phase) && sleep(0.1)
          processes[0].finish.wait
          processes[1].finish.wait
        end
      end.to raise_error(Fork::UndumpableException, /StateMachine::InvalidTransition/)
      expect(contest_request.lookbook.lookbook_details.where(phase: 'collaboration').count).to eq 1
    end
  end

end
