require "rails_helper"

RSpec.describe ContestPolicies do
  context 'contest in submission' do
    let(:contest) { Fabricate(:contest_in_submission) }

    it 'creates class instance' do
      expect(ContestPolicies.new(contest).invite_designers_page_accessible?).to be_truthy
    end
  end

  context 'contest during winner selection' do
    let(:contest) { Fabricate(:contest_during_winner_selection) }

    it 'creates class instance' do
      expect(ContestPolicies.new(contest).invite_designers_page_accessible?).to be_falsey
    end
  end

end
