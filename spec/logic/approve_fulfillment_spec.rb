require 'rails_helper'

RSpec.describe ApproveFulfillment do

  let(:client){ Fabricate(:client) }
  let(:designer){ Fabricate(:designer) }
  let(:contest){ Fabricate(:contest_in_submission, client: client) }
  let(:request)do
    request = Fabricate(:contest_request,
              designer: designer,
              status: 'submitted',
              answer: 'winner',
              contest_id: contest.id)
    SelectWinner.perform(request)
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
    expect{ ApproveFulfillment.perform(approved_request) }.to raise_error(ArgumentError)
  end

  it 'creates notification for fulfillment_ready request' do
    ApproveFulfillment.perform(request)
    expect(UserNotification.exists?(user_id: request.designer_id,
                                    contest_id: request.contest_id,
                                    type: 'DesignerInfoNotification')).to eq(true)
  end

  context 'when valid contest request' do
    it 'approves fulfillment_ready request' do
      ApproveFulfillment.perform(request)
      expect(request.status).to eq('fulfillment_approved')
    end

    it 'creates email for the designer' do
      ApproveFulfillment.perform(request)
      expect(jobs_with_handler_like('client_ready_for_final_design').count).to eq 1
    end

    it 'creates email to product owner' do
      ApproveFulfillment.perform(request)
      expect(jobs_with_handler_like('client_moved_to_final_design').count).to eq 1
    end
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
      ApproveFulfillment.perform(request)
      expect(request.image_items.final_design.pluck(:name)).to(
        match_array ['published_item_without_mark', 'liked_published_item']
      )
    end

    context 'on concurrent calls', concurrent: true do
      let!(:approve_fulfillment) { ApproveFulfillment.new(request) }

      it 'finalizes image items only once' do
        expect do
          approve_fulfillment.concurrent_calls([:ensure_correct_status, :update_status], :perform) do |processes|
            processes[0].run_until(:ensure_correct_status).wait
            processes[0].run_until(:update_status).wait
            processes[1].run_until(:ensure_correct_status) && sleep(0.5) # waiting would cause deadlock
            processes[1].run_until(:update_status) && sleep(0.5)
            processes[0].finish.wait
            processes[1].finish.wait
          end
        end.to raise_exception(ArgumentError)

        expect(request.reload.image_items.final_design.pluck(:name)).to(
            match_array ['published_item_without_mark', 'liked_published_item']
        )
      end
    end
  end

  it 'moves the contest to the final_fulfillment status' do
    ApproveFulfillment.perform(request)
    expect(contest.reload).to be_final_fulfillment
  end

end
