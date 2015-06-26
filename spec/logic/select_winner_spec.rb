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

end
