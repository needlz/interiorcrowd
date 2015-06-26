require 'rails_helper'

RSpec.describe ContestMilestone do

  let(:client) { Fabricate(:client) }

  describe '#end_milestone_performer_class' do
    let(:milestone){ ContestMilestone.new(contest) }

    context 'contest in submission status' do
      let(:contest) { Fabricate(:contest, client: client, status: 'submission') }

      it 'returns class of performer of milestone end' do
        expect(milestone.end_milestone_performer_class).to be_present
      end
    end

    context 'contest in winner_selection status' do
      let(:contest) { Fabricate(:contest, client: client, status: 'winner_selection') }

      it 'returns class of performer of milestone end' do
        expect(milestone.end_milestone_performer_class).to be_present
      end
    end

    context 'contest in fulfillment status' do
      let(:contest) { Fabricate(:contest, client: client, status: 'fulfillment') }

      it 'does not return class of performer of milestone end' do
        expect(milestone.end_milestone_performer_class).to be_blank
      end
    end

  end

end
