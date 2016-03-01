require 'rails_helper'

RSpec.describe Jobs::CheckIfBoardsReceived do

  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:contest_in_submission, client: client) }
  let(:contest_request) { Fabricate(:contest_request, contest: contest) }
  let(:job) { Jobs::CheckIfBoardsReceived.new(contest.id) }


  context 'contest in submission state and have no concept boards' do
    it 'notifies client' do
      job.perform
      expect(jobs_with_handler_like('no_concept_boards_received_after_three_days').count).to eq 1
    end
  end

  context 'contest not in submission state' do
    before do
      contest.start_winner_selection!
    end

    it 'does not notify client' do
      job.perform
      expect(jobs_with_handler_like('no_concept_boards_received_after_three_days').count).to eq 0
    end
  end

  context 'contest have concept boards' do
    before do
      contest_request
    end

    it 'does not notify client' do
      job.perform
      expect(jobs_with_handler_like('no_concept_boards_received_after_three_days').count).to eq 0
    end
  end

end
