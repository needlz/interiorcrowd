require 'rails_helper'

RSpec.describe EndSubmission do

  context 'contest has no submitted concept boards' do
    let(:contest) { Fabricate(:contest_in_submission) }

    it 'closes when submission ends' do
      EndSubmission.new(contest).perform
      expect(contest.status).to eq('closed')
    end

    it 'set the date of the finish' do
      EndSubmission.new(contest).perform
      expect(contest.finished_at).to be_within(5.seconds).of(Time.now)
    end

    it "doesn't close if the contest status is not correct" do
      contest.update_attributes(status: 'brief_pending')
      expect{ EndSubmission.new(contest).perform }.to raise_error(ArgumentError)
      expect(contest.reload.status).to eq('brief_pending')
      expect(contest.reload.finished_at).to be_nil
    end
  end

  context 'contest has submitted concept boards' do
    let(:contest) { Fabricate(:contest_in_submission) }
    let(:contest_request) { Fabricate(:contest_request, contest: contest) }

    before do
      contest_request
    end

    it "turns to the 'winner_selection' phase" do
      EndSubmission.new(contest).perform
      expect(contest.status).to eq('winner_selection')
    end

    it "fails to turn to the 'winner_selection' phase if the contest status is not correct" do
      contest.update_attributes(status: 'brief_pending')
      expect{ EndSubmission.new(contest).perform }.to raise_error(ArgumentError)
      expect(contest.reload.status).to eq('brief_pending')
    end
  end

end
