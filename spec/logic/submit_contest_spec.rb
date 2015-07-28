require 'rails_helper'

RSpec.describe SubmitContest do

  let(:client) { Fabricate(:client) }
  let(:contest) do
    contest_creation = ContestCreation.new(client_id: client.id, contest_params: contest_options_source)
    contest_creation.perform
  end

  it 'delays client notification about concept boards not received' do
    submit_contest = SubmitContest.new(contest)
    submit_contest.try_perform
    expect((jobs_with_handler_like('CheckIfBoardsReceived').first.run_at - 3.days - Time.current).abs < 1).to be_truthy
  end

end
