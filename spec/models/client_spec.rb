require "rails_helper"

RSpec.describe Client do

  let(:card_number) { '1234567812345678' }
  let(:last_four) { '5678' }
  let(:less_than_four_digits_card_number) { '159' }
  let(:less_than_four_digits_last_four) { '159' }

  let(:sample_client) { Fabricate(:client) }
  let(:credit_card1) { Fabricate(:credit_card) }
  let(:credit_card2) { Fabricate(:credit_card) }

  let(:client) {Fabricate(:client)}
  let(:client2) {Fabricate(:client)}

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

    context 'finished contest before closed' do
      let!(:finished_contest) { Fabricate(:contest, status: 'finished', client: client, created_at: 1.days.ago) }
      let!(:closed_contest) { Fabricate(:contest, status: 'closed', client: client, created_at: Time.current) }

      it 'returns last finished contest' do
        expect(client.last_contest).to eq finished_contest
      end
    end
  end

  it 'can have multiple credit cards' do
    sample_client.credit_cards << credit_card1
    sample_client.credit_cards << credit_card2
    sample_client.reload

    expect(sample_client.credit_cards).to match_array([credit_card1, credit_card2])
  end

  it 'can have primary card' do
    sample_client.primary_card = credit_card1
    sample_client.save

    saved_client = Client.find(sample_client)

    expect(saved_client.primary_card).to eq(credit_card1)
  end

end
