require "rails_helper"

RSpec.describe BudgetPlan do

  let(:client){ Fabricate(:client) }
  let(:designer){ Fabricate(:designer) }
  let(:contest){ Fabricate(:contest, client: client, status: 'submission') }
  let(:request){ Fabricate(:contest_request,
                           designer: designer,
                           status: 'fulfillment_ready',
                           answer: 'winner',
                           contest_id: contest.id) }
  let(:approved_request){ Fabricate(:contest_request,
                                    designer: designer,
                                    status: 'fulfillment_approved',
                                    answer: 'winner',
                                    contest_id: contest.id) }

  it 'does not create notification for fulfillment_approved request' do
    approve_fulfillment = ApproveFulfillment.new(approved_request)
    approve_fulfillment.perform
    expect(UserNotification.exists?(user_id: approved_request.designer_id,
                                    contest_id: approved_request.contest_id,
                                    type: 'DesignerInfoNotification')).to eq(false)
  end

  it 'creates notification for fulfillment_ready request' do
    approve_fulfillment = ApproveFulfillment.new(request)
    approve_fulfillment.perform
    expect(UserNotification.exists?(user_id: request.designer_id,
                                    contest_id: request.contest_id,
                                    type: 'DesignerInfoNotification')).to eq(true)
  end

  it 'approves fulfillment_ready request' do
    approve_fulfillment = ApproveFulfillment.new(request)
    approve_fulfillment.perform
    expect(request.status).to eq('fulfillment_approved')
  end

  it 'approves fulfillment_ready request' do
    approve_fulfillment = ApproveFulfillment.new(request)
    approve_fulfillment.perform
    expect(jobs_with_handler_like('client_ready_for_final_design').count).to eq 1
  end

end
