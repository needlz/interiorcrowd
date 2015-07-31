require 'rails_helper'

RSpec.describe FinishContestRequest do

  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:contest, client: client, status: 'final_fulfillment') }
  let(:designer) { Fabricate(:designer) }
  let(:contest_request) { Fabricate(:contest_request,
                                    contest: contest,
                                    designer: designer,
                                    status: 'fulfillment_approved') }

  it 'notifies client' do
    finish_contest_request = FinishContestRequest.new(contest_request)
    finish_contest_request.perform
    expect(jobs_with_handler_like('designer_submitted_final_design').count).to eq 1
  end

end
