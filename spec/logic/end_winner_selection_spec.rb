require 'rails_helper'

RSpec.describe EndWinnerSelection do

  let(:client){ Fabricate(:client) }
  let(:contest) { Fabricate(:completed_contest, status: 'winner_selection', client: client) }

  it 'reminds about winner selection' do
    EndWinnerSelection.new(contest).perform
    expect(jobs_with_handler_like('remind_about_picking_winner').count).to eq 1
  end

  it 'notifies designers' do
    designers_count = 4
    Fabricate.times(designers_count, :contest_request, contest: contest, status: 'submitted') do
      designer { Fabricate(:designer) }
    end
    EndWinnerSelection.new(contest).perform
    mailer_jobs_count = 1
    expect(jobs_with_handler_like('client_hasnt_picked_a_winner_to_designers').count).to eq mailer_jobs_count
  end

end
