require "rails_helper"

RSpec.describe ContestRequest do

  let(:card_number) { '1234567812345678' }
  let(:last_four) { '5678' }
  let(:less_than_four_digits_card_number) { '159' }
  let(:less_than_four_digits_last_four) { '159' }

  let(:client) {Fabricate(:client, card_number: card_number)}
  let(:client2) {Fabricate(:client, card_number: less_than_four_digits_card_number)}


  it 'return last 4 digits of credit card' do
    expect(client.card_number).to eq card_number
    expect(client.last_four_card_digits).to eq last_four
  end

  it 'return all digits if card number less than 4 digits' do
    expect(client2.card_number).to eq less_than_four_digits_card_number
    expect(client2.last_four_card_digits).to eq less_than_four_digits_last_four
  end

  describe '#last_contest' do
    context 'active contest before inactive' do
      let!(:finished_contest) { Fabricate(:contest, status: 'finished', client: client, created_at: 2.days.ago) }
      let!(:pending_contest) { Fabricate(:contest, status: 'brief_pending', client: client, created_at: 1.days.ago) }
      let!(:closed_contest) { Fabricate(:contest, status: 'closed', client: client, created_at: Time.current) }

      it 'returns last active contest' do
        expect(client.last_contest).to eq pending_contest
      end
    end

    context 'active contest is the last' do
      let!(:finished_contest) { Fabricate(:contest, status: 'finished', client: client, created_at: 3.days.ago) }
      let!(:fulfillment_contest) { Fabricate(:contest, status: 'fulfillment', client: client, created_at: 2.days.ago) }
      let!(:pending_contest) { Fabricate(:contest, status: 'brief_pending', client: client, created_at: 1.days.ago) }
      let!(:submission_contest) { Fabricate(:contest, status: 'submission', client: client, created_at: Time.current) }

      it 'returns last active contest' do
        expect(client.last_contest).to eq submission_contest
      end
    end

    context 'no active contests' do
      let!(:finished_contest) { Fabricate(:contest, status: 'finished', client: client, created_at: 1.days.ago) }
      let!(:pending_contest) { Fabricate(:contest, status: 'brief_pending', client: client, created_at: Time.current) }

      it 'returns last inactive contest' do
        expect(client.last_contest).to eq pending_contest
      end
    end
  end

end
