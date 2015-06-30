require 'rails_helper'

RSpec.describe SubmitContest do

  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:contest, client: client, status: 'brief_pending') }

  it 'delays client notification about concept boards not received' do
    submit_contest = SubmitContest.new(contest)
    submit_contest.perform
    expect((jobs_with_handler_like('CheckIfBoardsReceived').first.run_at - 3.days - Time.current).abs < 1).to be_truthy
  end

end
