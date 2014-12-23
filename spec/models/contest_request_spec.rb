require "rails_helper"

RSpec.describe ContestRequest do

  let(:designer) { Fabricate(:designer) }
  let(:contest) { Fabricate(:contest) }

  it 'validates uniqueness of designer response per contest' do
    contest.requests << Fabricate(:contest_request, designer: designer)
    expect(contest.requests.count).to eq 1
    contest.requests << Fabricate(:contest_request, designer: designer)
    expect(contest.requests.count).to eq 1
  end

  describe 'contest status validation' do
    it 'allows request to be submitted if contest is in submission state' do
      expect(contest.requests).to be_empty
      contest.requests << Fabricate(:contest_request, designer: designer, status: 'submitted')
      expect(contest.requests.reload).to be_present
    end

    it 'does not allow request to be submitted if contest is not in submission state' do
      expect(contest.requests).to be_empty
      contest.close!
      request = Fabricate(:contest_request, designer: designer, status: 'submitted')
      contest.requests << request
      expect(contest.requests.reload).to be_empty
    end
  end
end
