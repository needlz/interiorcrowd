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

  it 'allows to set answer in submission state' do
    request = Fabricate(:contest_request, designer: designer, status: 'submitted', contest: contest)
    request.update_attributes!(answer: 'no')
  end

  describe 'winner count validation' do
    let!(:request) { Fabricate(:contest_request, status: 'submitted', designer: Fabricate(:designer), contest: contest) }
    let!(:other_request) { Fabricate(:contest_request, status: 'submitted', designer: Fabricate(:designer), contest: contest) }

    before do
      contest.update_attributes!(status: 'winner_selection')
    end

    it 'does not allow to select more than one winner' do
      request.update_attributes!(answer: 'winner')
      expect { other_request.update_attributes!(answer: 'winner') }.to raise_error
    end

    it 'allows to select more than one winner' do
      request.update_attributes!(answer: 'winner')
      expect(request.answer).to eq 'winner'
    end
  end

  describe '#concept_board_image' do
    let(:request_with_lookbook_item){ Fabricate(:contest_request, designer: designer, lookbook: Fabricate(:lookbook)) }
    let(:request_without_lookbook_items){ Fabricate(:contest_request, designer: designer, lookbook: Lookbook.create!) }

    context 'uploaded lookbook item present' do
      it 'returns concept moodboard image' do
        expect(request_with_lookbook_item.concept_board_image).to be_present
      end
    end

    context 'there is no uploaded lookbook item' do
      it 'returns nil' do
        expect(request_without_lookbook_items.concept_board_image).to be_nil
      end
    end
  end

  describe '#reply' do
    let(:request){ Fabricate(:contest_request, designer: designer, status: 'fulfillment', answer: 'winner', contest_id: contest.id) }
    let(:submitted_request){ Fabricate(:contest_request, designer: designer, status: 'submitted', answer: 'maybe', contest_id: contest.id) }
    let(:client) { Fabricate(:client) }
    let(:contest) { Fabricate(:contest, client_id: client.id) }

    it 'does not change answer for fullfillment request' do
      request.reply('maybe', client.id)
      expect(request.answer).to eq('winner')
    end

    it 'changes answer for fullfillment request' do
      submitted_request.reply('favorite', client.id)
      expect(submitted_request.answer).to eq('favorite')
    end
  end

  describe '#approve' do
    let(:request){ Fabricate(:contest_request, designer: designer, status: 'fulfillment_ready', answer: 'winner', contest_id: contest.id) }
    let(:approved_request){ Fabricate(:contest_request, designer: designer, status: 'fulfillment_approved', answer: 'winner', contest_id: contest.id) }

    it 'does not create notification for fulfillment_approved request' do
      approved_request.approve
      expect(UserNotification.exists?(user_id: approved_request.designer_id, contest_id: approved_request.contest_id, type: 'DesignerInfoNotification')).to eq(false)
    end

    it 'creates notification for fulfillment_ready request' do
      request.approve
      expect(UserNotification.exists?(user_id: request.designer_id, contest_id: request.contest_id, type: 'DesignerInfoNotification')).to eq(true)
    end

    it 'approves fulfillment_ready request' do
      request.approve
      expect(request.status).to eq('fulfillment_approved')
    end
  end

  it 'sets unique token after creation' do
    request = Fabricate(:contest_request, designer: designer, contest_id: contest.id)
    expect(request.token).to be_present
  end

  it 'can be edited if not closed' do
    request = Fabricate(:contest_request, status: 'submitted', designer: Fabricate(:designer), contest: contest)
    expect(request.editable?).to be_truthy
  end

  it 'can not be edited if closed' do
    request = Fabricate(:contest_request, status: 'closed', designer: Fabricate(:designer), contest: contest)
    expect(request.editable?).to be_falsy
  end

  it 'can not be edited if finished' do
    request = Fabricate(:contest_request, status: 'finished', designer: Fabricate(:designer), contest: contest)
    expect(request.editable?).to be_falsy
  end

  it 'can not be edited if contest closed' do
    request = Fabricate(:contest_request, status: 'submitted', designer: Fabricate(:designer), contest: contest)
    contest.update_attributes!(status: 'closed')
    expect(request.editable?).to be_falsy
  end

  describe 'winner selection' do
    let(:request){ Fabricate(:contest_request, designer: designer, status: 'submitted', contest_id: contest.id) }

    it 'creates default product item' do
      request.update_attributes!(answer: 'winner')
      expect(request.product_items.count).to eq 1
    end

    it 'creates default similar style item' do
      request.update_attributes!(answer: 'winner')
      expect(request.similar_styles.count).to eq 1
    end
  end
end
