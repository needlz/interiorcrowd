require "rails_helper"

RSpec.describe ContestRequest do

  let(:designer) { Fabricate(:designer) }
  let(:contest) { Fabricate(:contest, status: 'submission') }

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

  it 'allows to set answer in submission state' do
    request = Fabricate(:contest_request, designer: designer, status: 'submitted', contest: contest)
    request.update_attributes!(answer: 'no')
  end

  describe 'winner count validation' do
    let!(:request) { Fabricate(:contest_request,
                               status: 'submitted',
                               designer: Fabricate(:designer),
                               contest: contest) }
    let!(:other_request) { Fabricate(:contest_request,
                                     status: 'submitted',
                                     designer: Fabricate(:designer),
                                     contest: contest) }

    before do
      contest.update_attributes!(status: 'winner_selection')
    end

    it 'does not allow to select more than one winner' do
      request.update_attributes!(answer: 'winner')
      expect { other_request.update_attributes!(answer: 'winner') }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'allows to select more than one winner' do
      request.update_attributes!(answer: 'winner')
      expect(request.answer).to eq 'winner'
    end
  end

  describe '#concept_board_image' do
    let(:request_with_lookbook_item){ Fabricate(:contest_request,
                                                designer: designer,
                                                lookbook: Fabricate(:lookbook)) }
    let(:request_without_lookbook_items){ Fabricate(:contest_request,
                                                    designer: designer,
                                                    lookbook: Lookbook.create!) }

    context 'uploaded lookbook item present' do
      it 'returns concept moodboard image' do
        expect(request_with_lookbook_item.concept_board_current_image).to be_present
      end
    end

    context 'there is no uploaded lookbook item' do
      it 'returns nil' do
        expect(request_without_lookbook_items.concept_board_current_image).to be_nil
      end
    end
  end

  describe '#reply' do
    let(:request){ Fabricate(:contest_request,
                             designer: designer,
                             status: 'fulfillment_ready',
                             answer: 'winner',
                             contest_id: contest.id) }
    let(:submitted_request){ Fabricate(:contest_request,
                                       designer: designer,
                                       status: 'submitted',
                                       answer: 'maybe',
                                       contest_id: contest.id) }
    let(:client) { Fabricate(:client) }
    let(:contest) { Fabricate(:contest,
                              client_id: client.id,
                              status: 'submission') }

    it 'does not change answer for fulfillment request' do
      request.reply('maybe', client.id)
      expect(request.answer).to eq('winner')
    end

    it 'changes answer for fulfillment request' do
      submitted_request.reply('favorite', client.id)
      expect(submitted_request.answer).to eq('favorite')
    end
  end

  it 'sets unique token after creation' do
    request = Fabricate(:contest_request,
                        designer: designer,
                        contest_id: contest.id)
    expect(request.token).to be_present
  end

  it 'can be edited if not closed' do
    request = Fabricate(:contest_request,
                        status: 'submitted',
                        designer: Fabricate(:designer),
                        contest: contest)
    expect(request.editable?).to be_truthy
  end

  it 'can not be edited if closed' do
    request = Fabricate(:contest_request,
                        status: 'closed',
                        designer: Fabricate(:designer),
                        contest: contest)
    expect(request.editable?).to be_falsy
  end

  it 'can not be edited if finished' do
    request = Fabricate(:contest_request,
                        status: 'finished',
                        designer: Fabricate(:designer),
                        contest: contest)
    expect(request.editable?).to be_falsy
  end

  it 'can not be edited if contest closed' do
    request = Fabricate(:contest_request,
                        status: 'submitted',
                        designer: Fabricate(:designer),
                        contest: contest)
    contest.update_attributes!(status: 'closed')
    expect(request.editable?).to be_falsy
  end

  describe 'winner selection' do
    let(:request){ Fabricate(:contest_request,
                             designer: designer,
                             status: 'submitted',
                             contest_id: contest.id) }

    it 'does not create default items if an item already present' do
      request.product_items.create!(kind: 'product_items')
      expect(request.product_items.count).to eq 1
      request.update_attributes!(answer: 'winner')
      expect(request.product_items.count).to eq 1
    end
  end

  describe '#cover_image' do
    let(:request) do
      Fabricate(:contest_request,
                designer: designer,
                status: 'submitted',
                contest_id: contest.id,
      lookbook: Fabricate(:lookbook))
    end
    let(:phase) { 'collaboration' }


    context 'when no images in selected phase' do
      before do
        Fabricate(:lookbook_image, phase: 'initial', lookbook: request.lookbook)
      end

      it 'returns nil' do
        expect(request.cover_image(phase)).to be_nil
      end
    end

    context 'when there are images in selected phase' do
      before do
        Fabricate.times(2, :lookbook_image, lookbook: request.lookbook, phase: 'initial')
        Fabricate.times(2, :lookbook_image, lookbook: request.lookbook, phase: phase)
      end

      let(:last_image) { Fabricate(:image) }

      it 'returns last image' do
        expect(request.cover_image(phase)).to be_present
        Fabricate(:lookbook_detail, phase: 'collaboration', image: last_image, lookbook: request.lookbook)
        expect(request.cover_image(phase)).to eq last_image
      end
    end

  end

  describe '#has_designer_comments scope' do
    let(:contest_request) { Fabricate(:contest_request) }

    context 'client created comment on contest request' do
      let(:client_comment) { Fabricate(:concept_board_client_comment, contest_request: contest_request) }

      it 'returns no contest requests' do
        client_comment
        expect(ContestRequest.last.comments.count).to eq(1)
        expect(ContestRequest.has_designer_comments).not_to be_present
      end
    end

    context 'designer created comment on contest request' do
      let(:designer_comment) { Fabricate(:concept_board_designer_comment, contest_request: contest_request) }
      let(:designer) { Fabricate(:designer) }
      let(:request_with_client_comment) { Fabricate(:contest_request, designer: designer) }
      let(:client_comment) { Fabricate(:concept_board_client_comment, contest_request: request_with_client_comment) }

      it 'returns contest requests which have comments created on them' do
        designer_comment
        expect(ContestRequest.last.comments.count).to eq(1)
        expect(ContestRequest.has_designer_comments.last.comments.count).to eq(1)
      end

      it 'return only contest requests which have designer comments' do
        designer_comment
        client_comment
        expect(ContestRequest.all.count).to eq(2)
        expect(ContestRequest.has_designer_comments.count).to eq(1)
      end
    end
  end

  describe '#client_sees_in_entries scope' do
    let(:contest_request) { Fabricate(:contest_request) }
    let(:designer_comment) { Fabricate(:concept_board_designer_comment, contest_request: contest_request) }
    let(:designer) { Fabricate(:designer) }
    let(:closed_request) { Fabricate(:closed_request, designer: designer) }
    let(:another_designer) { Fabricate(:designer) }
    let(:another_request) { Fabricate(:draft_request, designer: another_designer) }

    it 'returns only commented contest requests and not draft requests' do
      designer_comment
      closed_request
      another_request
      expect(another_request.status).to eq('draft')
      expect(ContestRequest.client_sees_in_entries).to match_array([contest_request, closed_request])
    end
  end

  describe '#lookbook_items_by_phase' do
    let(:contest_request) { Fabricate(:contest_request) }

    context 'when there are no lookbook items in requested phase' do
      it 'returns mappable value' do
        expect(contest_request.lookbook_items_by_phase(:initial).respond_to?(:map)).to be_truthy
      end
    end
  end

end
