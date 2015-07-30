require 'rails_helper'

RSpec.describe ApproveFulfillment do

  let(:client){ Fabricate(:client) }
  let(:designer){ Fabricate(:designer) }
  let(:contest){ Fabricate(:contest, client: client, status: 'submission') }
  let(:request)do
    request = Fabricate(:contest_request,
              designer: designer,
              status: 'submitted',
              answer: 'winner',
              contest_id: contest.id)
    SelectWinner.new(request).perform
    request
  end
  let(:approved_request)do
    request = Fabricate(:contest_request,
              designer: designer,
              status: 'fulfillment_approved',
              answer: 'winner',
              contest_id: contest.id)
  end

  it 'raises error if applied to non "fulfillment_ready" contest request' do
    approve_fulfillment = ApproveFulfillment.new(approved_request)
    expect{ approve_fulfillment.perform }.to raise_error(ArgumentError)
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

  it 'creates email for the designer' do
    approve_fulfillment = ApproveFulfillment.new(request)
    approve_fulfillment.perform
    expect(jobs_with_handler_like('client_ready_for_final_design').count).to eq 1
  end

  context 'when image items present' do
    let!(:published_item_without_mark) { Fabricate(:product_item,
                                                   status: 'published',
                                                   contest_request: request,
                                                   name: 'published_item_without_mark') }
    let!(:liked_temporary_item) { Fabricate(:product_item,
                                            status: 'temporary',
                                            contest_request: request,
                                            mark: ImageItem::MARKS[:LIKE],
                                            name: 'liked_temporary_item') }
    let!(:disliked_published_item) { Fabricate(:product_item,
                                               status: 'published',
                                               contest_request: request,
                                               mark: ImageItem::MARKS[:DISLIKE],
                                               name: 'disliked_published_item') }
    let!(:liked_published_item) { Fabricate(:product_item, status: 'published',
                                            contest_request: request,
                                            mark: ImageItem::MARKS[:LIKE],
                                            name: 'liked_published_item') }

    it 'creates final copies of published non-disliked image items' do
      approve_fulfillment = ApproveFulfillment.new(request)
      approve_fulfillment.perform
      expect(request.image_items.final_design.pluck(:name)).to(
        match_array ['published_item_without_mark', 'liked_published_item']
      )
    end
  end

  it 'moves the contest to the final_fulfillment status' do
    approve_fulfillment = ApproveFulfillment.new(request)
    approve_fulfillment.perform
    expect(contest.reload).to be_final_fulfillment
  end

end
