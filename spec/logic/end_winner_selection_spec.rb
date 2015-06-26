require 'rails_helper'

RSpec.describe EndWinnerSelection do

  let(:client){ Fabricate(:client) }
  let(:contest) { Fabricate(:contest, status: 'submission', client: client) }

  it 'remindes about winner selection' do
    EndWinnerSelection.new(contest).perform
    expect(jobs_with_handler_like(Jobs::Mailer.name).count).to eq 1
  end

end
