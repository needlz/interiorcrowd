require 'rails_helper'

RSpec.describe ContestMilestone do

  let(:client) { Fabricate(:client) }

  describe '#end_milestone_performer_class' do
    let(:milestone){ ContestMilestone.new(contest) }

    context 'contest in submission status' do
      let(:contest) { Fabricate(:contest_in_submission, client: client) }

      it 'returns class of performer of milestone end' do
        expect(milestone.end_milestone_performer_class).to be_present
      end
    end

    context 'contest in winner_selection status' do
      let(:contest) { Fabricate(:completed_contest, client: client, status: 'winner_selection') }

      it 'returns class of performer of milestone end' do
        expect(milestone.end_milestone_performer_class).to be_present
      end

      it 'delays phase end to the end of day' do
        expected_next_phase_end = (contest.phase_end + ContestMilestone::DAYS[contest.status].days).end_of_day
        expect(milestone.phase_end(contest.phase_end)).to eq expected_next_phase_end
      end
    end

    context 'contest in fulfillment status' do
      let(:contest) { Fabricate(:completed_contest, client: client, status: 'fulfillment') }

      it 'does not return class of performer of milestone end' do
        expect(milestone.end_milestone_performer_class).to be_blank
      end
    end

  end

end
